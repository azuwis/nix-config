# Architecture

## Repository overview

Personal Nix/NixOS configuration monorepo. Each target type has an OS directory; run `ls hosts/` for current host entry points (files with `hardware-` or `disk-` prefix are supporting config, not entry points), and see the table below for OS module roots:

| Type | OS dir | Notes |
|------|--------|-------|
| NixOS | `nixos/` | |
| nix-darwin | `darwin/` | |
| nix-on-droid | `droid/` | hostnames hardcoded in `flakes/droid.nix` (aarch64 for real devices, x86_64 for local testing on non-ARM machines) |
| OpenWrt | `openwrt/` | |
| solo | `solo/` | non-NixOS Linux, no root needed |

`scripts/os` is the primary operational interface -- run it without arguments to see commands. Most subcommands have short aliases: `b` (build), `s` (switch), `d` (diff), `cd` (configdiff), `dp` (deploy), `r` (run), `l` (list), `u`/`lu` (update), `c` (clean), `hw` (hardware), `dg` (direnv-gcroots), `slb` (show-local-builds). `os build` and `os switch` accept extra nix-build arguments before the hostname; `os -- <args>` passes arguments to the underlying rebuild tool.

`desktop/` provides desktop environment configs (run `ls desktop/` to see modules). Imported by `nixos/` and `darwin/` only.

## Before committing

```bash
./scripts/os run treefmt
```

Configuration in `apps/treefmt.nix`. Uses treefmt with nixfmt, shfmt, stylua, and yamlfmt.

## Common commands

```bash
./scripts/os build [<host>]  # build, show nvd diff vs current system
./scripts/os switch [<host>]  # build and activate
./scripts/os deploy [-f] [<host>]  # build and deploy to remote host (NixOS/OpenWrt), -f skips confirmation
./scripts/os diff [<host>]  # build and show detailed diff
./scripts/os configdiff <host> [<host2>]  # diff NixOS option values (single host: vs git HEAD; two hosts: host vs host)
./scripts/os run <app>  # run an app (looked up in apps/, then pkgs/)
./scripts/os update [all] [<input>] [<input>=<rev>] [-<exclude>]  # update input pins (custom input system)
./scripts/os hw  # generate hardware config (NixOS only)
./scripts/os list  # list system generations
./scripts/os ci <host>  # CI-style build (sets NIXLOCK_OVERRIDE_my=./test)
./scripts/os ns  # show custom input lock as table
```

The `test/` directory provides a minimal `default.nix` stub for the `my` input, so CI builds don't depend on private data.

Dry run: prefix with `dry` -- `./scripts/os dry build <host>`. Only affects commands routed through the build pipeline (build, switch, deploy, diff); standalone utility commands like `clean`, `hw`, `dg`, `ns`, `slb`, `run` execute normally even with `dry` prefix.

### Package updates

```bash
./scripts/update -la  # list packages with update scripts
./scripts/update -a  # update all
./scripts/update -a -c  # update all and auto-commit
./scripts/update <package-name>  # update a single package
./scripts/update -i <attrpath>  # show package info (homepage, changelog, repo, description)
```

`lib/update.nix` drives this system; `lib/info.nix` provides metadata lookups.

## Architecture

### Module discovery

Host files in `hosts/` are the entry points. Except for nix-on-droid (configured inline in `flakes/droid.nix`), each imports OS-level modules from the corresponding directory, which import `common/` and use `lib.my.getModules` to auto-discover all `default.nix` files in their directory tree. `openwrt/` only imports `common/my` (no desktop tools).

`common/` modules are auto-discovered -- each program or infrastructure concern lives in its own subdirectory with a `default.nix`, activated via `programs.<name>.enable` or equivalent. The only inline exception is `direnv` in `common/default.nix` (two lines, not worth a module). Run `ls -d common/*/ desktop/*/` to see current modules. Nested modules like `common/lazyvim/` call `getModules` from their parent, discovering sub-modules recursively.

`config.nix` holds nixpkgs configuration (`allowUnfreePredicate` whitelist, `allowAliases = false`), used by both `pkgs/default.nix` and `common/nixpkgs/default.nix`.

### Input system

This repo uses a **custom input system** (not flake inputs). Key files:

- `inputs/inputs.nix` -- declares inputs (URLs, types, freeze behavior)
- `inputs/lock.nix` -- pinned revisions (the lock file)
- `inputs/default.nix` -- resolves inputs; `--argstr update` triggers selective updates
- `inputs/show.nix` -- renders the lock as a table for `os ns`

`scripts/os update` calls `nix-instantiate` with update targets and writes a new `inputs/lock.nix`. `NIXLOCK_OVERRIDE_*` env vars override input paths locally (used by CI via `os ci`).

Note: `scripts/os fu` (flake-update) is obsolete. The repo uses the custom input system and `flake.nix` discards flake inputs (`outputs = _: ...`), so updating `flake.lock` has no effect.

### Input availability (circular dependency gotcha)

There are two mechanisms, and the distinction matters:

**`import ../inputs { }` (direct eval)** -- Required when a module references `inputs` in its `imports` block (e.g. `inputs.agenix.outPath + "/modules/age.nix"`). The module system evaluates `imports` before resolving function arguments, so receiving inputs via `{ inputs, ... }` in function args creates a circular dependency. Bind inputs locally via `let` instead.

**`_module.args.inputs = inputs` (module injection)** -- Set in `common/default.nix`. After the module system initializes, sub-modules receive inputs via function args without importing directly. Only works for modules that do NOT reference `inputs` in their `imports` block.

Run `grep 'import.*inputs' nixos/default.nix darwin/default.nix common/default.nix` to see current direct-eval patterns. OpenWrt passes inputs via `_module.args` directly; droid and solo don't use inputs.

### `runCommandLocal` vs `runCommand`

`runCommandLocal` = `runCommand` + `preferLocalBuild = true` + `allowSubstitutes = false`.

- **`runCommandLocal`** for instantaneous derivations (sed, ln, makeWrapper, cp, echo, mkdir -- under ~0.1s). The network round-trip for a cached substitute costs more than rebuilding locally.
- **`runCommand`** for derivations with real computation (rendering, `nps --refresh`, etc.).

Run `grep -r runCommandLocal pkgs/ --include='*.nix'` and `grep -r '\brunCommand\b' nixos/ --include='*.nix'` for current patterns.

### `scripts/os` behavior

Auto-detects OS type from hostname, uses OS-specific eval targets and activation scripts. Runs `nvd diff` after each build comparing against the current system. Distinguishes local vs remote builds via `FOROTHER` logic. Falls back to OS-native tools (`darwin-rebuild`, `nix-on-droid`, `nixos-rebuild`) for passthrough commands and listing generations. See the script itself for details.

### Solo variants

Three variants, auto-detected by checking `/nix/store` ownership and sticky bit:

- **solo** -- full user environment for non-NixOS Linux, activated via `nix-env --set` + home activation script
- **solo-shell** -- PATH-only variant, used via `scripts/solo-shell`. Does not include the shell in `systemPackages` to avoid infinite recursion: `solo-shell` sets `environment.variables.PATH` to `${config.solo.path}/bin`, `solo.path` builds from `systemPackages`, and adding the shell (which reads `environment.variables`) to `systemPackages` creates a module-system cycle.
- **solo-single** -- for single-user (no-daemon) Nix installations

`solo/compat/default.nix` bridges NixOS modules for non-NixOS: imports selected NixOS modules, stubs out NixOS-specific options, and uses `disabledModules` to exclude `common/system/default.nix`. Run `ls solo/` to see current submodules.

### linkdir module

`lib/linkdir.nix` provides declarative symlink forests (similar to home-manager's `home.file`). Supports inline text content, globbing, old-state tracking for cleanup, and safety (never replaces non-symlink files). Used by `common/home` and `openwrt/builder`.

### Flake wiring

`flake.nix` is a thin wrapper around `flakes/`; run `ls flakes/` to see current structure. `flakes/default.nix` aggregates all OS configurations. `devShells` auto-discover from `devshells/`, `packages` from overlays (only overlay-defined packages appear, not all of nixpkgs), `apps` from `apps/default.nix`.

Other notable files: `lib/configdiff.nix` (NixOS option-level diff), `overlays/` (custom overrides; run `ls overlays/` for current files), `pkgs/by-name/` (nixpkgs by-name convention packages).

### Custom packages and overlays

Overlays and custom packages follow these conventions:

- `pkgs/by-name/` -- nixpkgs by-name convention, loaded automatically via nixpkgs' `by-name-overlay.nix`
- `pkgs/wallpapers/` -- wallpaper collections, loaded via `packagesFromDirectoryRecursive` in `overlays/default.nix`
- `overlays/default.nix` -- central overlay: custom package overrides, wallpapers attr, agenix overlay import; also has commented-out lua/python/vim overlays
- `overlays/jovian.nix` -- per-host overlay pattern (Steam Deck), used only by `hosts/jovian.nix`
- `overlays/lix.nix` -- replaces packages with Lix-built variants; currently commented out

Language-specific example packages in `pkgs/python/`, `pkgs/lua/`, `pkgs/vim/` use `.example`-suffixed files that need renaming + overlay activation to use; run `ls -R pkgs/python/ pkgs/lua/ pkgs/vim/` to see them.

### CI

Workflows in `.github/workflows/`. Key behaviors:

- `host.yml` -- builds all hosts to Cachix, appends closure sizes to `data.csv` on `gh-pages`
- `update.yml` -- automated package updates via SSH deploy keys (not `GITHUB_TOKEN`, so PRs trigger downstream CI)
- `package.yml` -- builds single packages with a platform-skip cache
