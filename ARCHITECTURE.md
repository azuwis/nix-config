# Architecture

## Repository overview

Personal Nix/NixOS configuration monorepo. Each target type has an OS directory (see the table below); host entry points are in `hosts/` -- files with a `hardware-` or `disk-` prefix are supporting config, not entry points:

| Type | OS dir | Notes |
|------|--------|-------|
| NixOS | `nixos/` | |
| nix-darwin | `darwin/` | |
| nix-on-droid | `droid/` | hostnames hardcoded in `flakes/droid.nix` (aarch64 for real devices, x86_64 for CI) |
| OpenWrt | `openwrt/` | |
| solo | `solo/` | non-NixOS Linux, no root needed |

`scripts/os` is the primary operational interface: no arguments builds and switches the current host; `scripts/os -h` lists subcommands and aliases. `desktop/` provides desktop environment configs, imported by `nixos/` and `darwin/` only.

## Before committing

Run `./scripts/os run treefmt` (formatters configured in `apps/treefmt.nix`).

## Common commands

For commands and flags, run `./scripts/os -h` or `./scripts/update -h`.

Notes:

- The `test/` stub for the `my` input keeps CI builds independent of private data.
- `scripts/update` drives package updates through `lib/update.nix` (nixpkgs' `maintainers/scripts/update.py`); `lib/info.nix` backs `-i`.

## Core design

### Module discovery

Host files in `hosts/` are the entry points. Except for nix-on-droid (configured inline in `flakes/droid.nix`), each imports OS-level modules from the corresponding directory, which import `common/` and use `lib.my.getModules` to auto-discover all `default.nix` files in their directory tree (`openwrt/` only imports `common/my`, no desktop tools).

`common/` modules follow the same pattern: each program or infrastructure concern has its own subdirectory with a `default.nix`, activated via `programs.<name>.enable` or equivalent; nested modules like `common/lazyvim/` call `getModules` from their parent, discovering sub-modules recursively. The only inline exception is `direnv` in `common/default.nix` (not worth a module).

`config.nix` holds nixpkgs configuration (`allowUnfreePredicate` whitelist, `allowAliases = false`), used by both `pkgs/default.nix` and `common/nixpkgs/default.nix`.

### Input system

This repo uses a **custom input system** (not flake inputs). Key files:

- `inputs/inputs.nix` -- declares inputs (URLs, types, freeze behavior)
- `inputs/lock.nix` -- pinned revisions (the lock file)
- `inputs/default.nix` -- resolves inputs; `--argstr update` triggers selective updates
- `inputs/show.nix` -- renders the lock as a table for `os ns`

`scripts/os update` calls `nix-instantiate` with update targets and writes a new `inputs/lock.nix`. `NIXLOCK_OVERRIDE_*` env vars override input paths locally (used by CI via `os ci`). `scripts/os fu` (flake-update) is obsolete: `flake.nix` discards flake inputs (`outputs = _: ...`) and there is no tracked `flake.lock`.

### Input availability (circular dependency gotcha)

Inputs reach modules two ways:

- **Direct eval -- `import ../inputs { }`** -- Required when a module references `inputs` in its `imports` block (e.g. `inputs.agenix.outPath + "/modules/age.nix"`): the module system evaluates `imports` before resolving function arguments, so receiving inputs via `{ inputs, ... }` creates a circular dependency. Bind inputs locally via `let` instead.
- **Module injection -- `_module.args.inputs = inputs`** (set in `common/default.nix`) -- Sub-modules receive inputs via function args after the module system initializes, but only if they do NOT reference `inputs` in `imports`.

OpenWrt passes inputs via `_module.args` directly; droid and solo evaluate inputs directly in their `compat` modules.

### `runCommandLocal` vs `runCommand`

`runCommandLocal` = `runCommand` + `preferLocalBuild = true` + `allowSubstitutes = false`.

- **`runCommandLocal`** for instantaneous derivations (sed, ln, makeWrapper, cp, echo, mkdir -- under ~0.1s): the network round-trip for a cached substitute costs more than rebuilding locally.
- **`runCommand`** for derivations with real computation (rendering, `nps --refresh`, etc.).

### Solo variants

Three variants, selected by hostname against `flakes/solo.nix`, with a `/nix/store` ownership and sticky-bit fallback that picks `solo` vs `solo-single`:

- **solo** -- full user environment for non-NixOS Linux, activated via `nix-env --set` + home activation script
- **solo-shell** -- PATH-only variant, used via `scripts/solo-shell`. It sets `environment.variables.PATH` to `${config.solo.path}/bin:$PATH`, where `solo.path` builds from `systemPackages`; the shell itself stays out of `systemPackages` because it reads `environment.variables`, which would create a module-system cycle.
- **solo-single** -- for single-user (no-daemon) Nix installations

`solo/compat/default.nix` bridges NixOS modules for non-NixOS: imports selected NixOS modules, stubs out NixOS-specific options, and uses `disabledModules` to exclude `common/system/default.nix`.

### linkdir module

`lib/linkdir.nix` provides declarative symlink forests (`home.file`-style: inline text content, globbing, old-state tracking for cleanup, never replaces non-symlink files). Used by `common/home` and `openwrt/builder`.

### Flake wiring

`flake.nix` is a thin wrapper around `flakes/`. `flakes/default.nix` aggregates all OS configurations. `devShells` auto-discover from `devshells/`, `packages` from overlays (only overlay-defined packages appear, not all of nixpkgs), `apps` from `apps/default.nix`.

### Custom packages and overlays

- `pkgs/by-name/` -- nixpkgs by-name convention, loaded automatically via nixpkgs' `by-name-overlay.nix`
- `pkgs/wallpapers/` -- wallpaper collections, loaded via `packagesFromDirectoryRecursive` in `overlays/default.nix`
- `overlays/default.nix` -- central overlay: custom package overrides, wallpapers attr, agenix overlay import
- `overlays/jovian.nix` -- per-host overlay pattern (Steam Deck), used only by `hosts/jovian.nix`

### CI

Workflows in `.github/workflows/`. Key behaviors:

- `host.yml` -- builds a host matrix to Cachix, appends closure sizes to `data.csv` on `gh-pages`
- `update.yml` -- automated package updates pushed via SSH deploy keys rather than `GITHUB_TOKEN`, so PRs trigger downstream CI
- `package.yml` -- builds single packages with a platform-skip cache
