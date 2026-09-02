# Architecture

## Repository overview

Personal Nix/NixOS configuration monorepo. Host entry points are files in `hosts/` (a `hardware-` or `disk-` prefix marks supporting config, not an entry point). Each target type has an OS dir:

| Type | OS dir | Notes |
|------|--------|-------|
| NixOS | `nixos/` | |
| nix-darwin | `darwin/` | |
| nix-on-droid | `droid/` | hostnames hardcoded in `flakes/droid.nix` (aarch64 for real devices, x86_64 for CI) |
| OpenWrt | `openwrt/` | |
| solo | `solo/` | non-NixOS Linux, no root needed |

`scripts/os` is the primary operational interface: no args builds and switches the current host; `scripts/os -h` lists subcommands and aliases. `desktop/` holds desktop configs, imported by `nixos/` and `darwin/` only.

## Before committing

Run `./scripts/os run treefmt` (formatters configured in `apps/treefmt.nix`).

## Common commands

Commands and flags: `./scripts/os -h` or `./scripts/update -h`. Notes: the `test/` stub for the `my` input keeps CI builds independent of private data; `scripts/update` drives package updates through `lib/update.nix` (nixpkgs' `maintainers/scripts/update.py`); `lib/info.nix` backs `-i`.

## Core design

### Module discovery

Except nix-on-droid (inline in `flakes/droid.nix`), each host imports OS-level modules from its directory, which import `common/` and use `lib.my.getModules` to auto-discover all `default.nix` files in their directory tree (`openwrt/` imports only `common/my`, no desktop tools). `common/` follows the same pattern: each program or infrastructure concern has its own subdirectory with a `default.nix`, activated via `programs.<name>.enable` or equivalent; nested modules like `common/lazyvim/` call `getModules` from their parent, discovering sub-modules recursively. The only inline exception is `direnv` in `common/default.nix` (not worth a module). `config.nix` holds nixpkgs configuration (`allowUnfreePredicate` whitelist, `allowAliases = false`), used by `pkgs/default.nix` and `common/nixpkgs/default.nix`.

### Input system

**Custom input system** (not flake inputs):

- `inputs/inputs.nix`: declares inputs (URLs, types, freeze behavior)
- `inputs/lock.nix`: pinned revisions (the lock file)
- `inputs/default.nix`: resolves inputs; `--argstr update` triggers selective updates
- `inputs/show.nix`: renders the lock as a table for `os ns`

`scripts/os update` calls `nix-instantiate` with update targets and writes a new `inputs/lock.nix`; `NIXLOCK_OVERRIDE_*` env vars override input paths locally (used by CI via `os ci`). `scripts/os fu` (flake-update) is obsolete: `flake.nix` discards flake inputs (`outputs = _: ...`) and no `flake.lock` is tracked.

### Input availability (circular dependency gotcha)

Inputs reach modules two ways:

- **Direct eval: `import ../inputs { }`** for modules referencing `inputs` in `imports` (e.g. `inputs.agenix.outPath + "/modules/age.nix"`): `imports` is evaluated before function arguments resolve, so `{ inputs, ... }` creates a circular dependency. Bind inputs locally via `let` instead.
- **Module injection: `_module.args.inputs = inputs`** (set in `common/default.nix`): sub-modules receive inputs via function args after the module system initializes, but only if they do NOT reference `inputs` in `imports`.

OpenWrt passes inputs via `_module.args` directly; droid and solo evaluate inputs directly in their `compat` modules.

### `runCommandLocal` vs `runCommand`

`runCommandLocal` = `runCommand` + `preferLocalBuild = true` + `allowSubstitutes = false`. Use it for instantaneous derivations (sed, ln, makeWrapper, cp, echo, mkdir, all under ~0.1s): a cached substitute's network round-trip costs more than a local rebuild. Use `runCommand` for real computation (rendering, `nps --refresh`, etc.).

### Solo variants

Three variants, selected by hostname against `flakes/solo.nix`, with a `/nix/store` ownership + sticky-bit fallback that picks `solo` vs `solo-single`:

- **solo**: full user environment for non-NixOS Linux, activated via `nix-env --set` + home activation script
- **solo-shell**: PATH-only variant, used via `scripts/solo-shell`. It sets `environment.variables.PATH` to `${config.solo.path}/bin:$PATH` (`solo.path` builds from `systemPackages`); the shell stays out of `systemPackages` because it reads `environment.variables`, which would create a module-system cycle
- **solo-single**: for single-user (no-daemon) Nix installations

`solo/compat/default.nix` bridges NixOS modules for non-NixOS: imports selected NixOS modules, stubs NixOS-specific options, and uses `disabledModules` to exclude `common/system/default.nix`.

### linkdir module

`lib/linkdir.nix` provides declarative symlink forests (`home.file`-style: inline text content, globbing, old-state tracking for cleanup, never replaces non-symlink files); used by `common/home` and `openwrt/builder`.

### Flake wiring

`flake.nix` is a thin wrapper around `flakes/`; `flakes/default.nix` aggregates all OS configurations. `devShells` auto-discover from `devshells/`, `packages` from overlays (only overlay-defined packages appear, not all of nixpkgs), `apps` from `apps/default.nix`.

### Custom packages and overlays

- `pkgs/by-name/`: nixpkgs by-name convention, loaded automatically via nixpkgs' `by-name-overlay.nix`
- `pkgs/wallpapers/`: wallpaper collections, loaded via `packagesFromDirectoryRecursive` in `overlays/default.nix`
- `overlays/default.nix`: central overlay with custom package overrides, wallpapers attr, agenix overlay import
- `overlays/jovian.nix`: per-host overlay pattern (Steam Deck), used only by `hosts/jovian.nix`

### CI

Workflows in `.github/workflows/`:

- `host.yml`: builds a host matrix to Cachix, appends closure sizes to `data.csv` on `gh-pages`
- `update.yml`: automated package updates pushed via SSH deploy keys rather than `GITHUB_TOKEN`, so PRs trigger downstream CI
- `package.yml`: builds single packages with a platform-skip cache
