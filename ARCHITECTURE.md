# Architecture

## Repository overview

Personal Nix/NixOS configuration monorepo managing hosts across these target types:
- **NixOS** (Linux; `nixos/`, `hosts/{aor,hyperv,jovian,nuc,utm,wsl}.nix`)
- **nix-darwin** (macOS; `darwin/`, `hosts/mbp.nix`)
- **nix-on-droid** (Android/Termux; `droid/`, hostnames hardcoded as `droid-arm` and `droid` in `flakes/droid.nix`)
- **OpenWrt** (WiFi routers; `openwrt/`, `hosts/{wg3526,xr500}.nix`)
- **solo** (user environments for non-NixOS Linux, no root needed; `solo/`, `hosts/{solo,solo-shell,solo-single}.nix`)

Additional `hosts/` files (`hardware-*.nix`, `disk-aor.nix`) are supporting config (hardware specs, disk partitioning), not host entry points.

`desktop/` provides desktop environment configurations; use `ls desktop/` to see current modules. Imported by `nixos/` and `darwin/`.

`scripts/os` is the primary operational interface for all hosts.

Most commands have short aliases: `b` (build), `s` (switch), `d` (diff), `cd` (configdiff), `dp` (deploy), `r` (run), `l` (list), `u`/`lu` (update), `ns` (nixlock-show), `c` (clean), `hw` (hardware), `dg` (direnv-gcroots), `slb` (show-local-builds). `os build` and `os switch` accept extra nix-build arguments before the hostname. `os -- <args>` passes arguments directly to the underlying rebuild tool (`darwin-rebuild`, `nix-on-droid`, or `nixos-rebuild`).

## Before committing

After modifying any code, run the formatter:

```bash
./scripts/os run treefmt
```

Configuration lives in `apps/treefmt.nix`. Uses `treefmt` with nixfmt, shfmt, stylua, and yamlfmt.

## Common commands

```bash
# Build a host (auto-detects OS type from hostname)
./scripts/os build [<host>]                  # build only, show diff vs current system
./scripts/os switch [<host>]                 # build and activate
./scripts/os deploy [-f] [<host>]            # build and deploy to remote host (NixOS/OpenWrt), -f skips confirmation
./scripts/os diff [<host>]                   # build and show detailed diff
./scripts/os configdiff <host> [<host2>]     # diff NixOS option values between hosts (single host: diff against git HEAD)
./scripts/os run <app>                       # run an app (looked up in apps/, then pkgs/)

# Update package pins (custom input system, not flake inputs)
./scripts/os update [all] [<input>] [<input>=<rev>] [-<exclude-input>]

# Generate hardware config for current machine (NixOS only)
./scripts/os hw

# List system generations
./scripts/os list
```

### Updating custom packages

```bash
./scripts/update -la                         # list packages with update scripts
./scripts/update -a                          # update all
./scripts/update -a -c                       # update all and auto-commit
./scripts/update <package-name>              # update a single package
```

### Custom input lock display

```bash
./scripts/os ns                              # show custom input lock as a table (name, date, rev, cached?, url)
```

Renders locked input revisions using `inputs/show.nix`. This is the **custom input system** (not flake.lock).

### Obsolete commands

```bash
./scripts/os fu [<input>]                    # (obsolete) update flake.lock, no longer used; repo uses the custom input system instead
```

### Dry run

```bash
./scripts/os dry build <host>                # show what would be built and the diff, without executing
./scripts/os dry switch <host>               # show what would be activated, without switching
```

Prepends `Dry run:` to commands and prints them without execution. Only affects commands routed through `run_command` (the build pipeline); standalone utility commands execute normally.

### Other useful commands

```bash
./scripts/os c                               # clean broken gcroots symlinks
./scripts/os slb [<path>]                    # show derivations built locally (not substituted) in a closure
./scripts/os dg                              # list all nix-direnv gcroots via nix-tree
```

### solo (non-NixOS environments)

```bash
./scripts/os switch                          # auto-detects solo (any hostname not in other configuration attrsets)
./scripts/solo-shell                         # drop into a sub-shell with the solo environment
```

Any hostname not found in other configuration attrsets (nixos, darwin, droid, openwrt) falls through to solo. The script then auto-detects solo vs solo-single by checking `/nix/store` ownership and sticky bit.

### Testing

```bash
# CI-style build with test overrides (sets NIXLOCK_OVERRIDE_my=./test)
./scripts/os ci <host>
```

The `test/` directory provides a minimal `default.nix` used as an override for the `my` input during CI builds, so CI doesn't depend on private data from the real `my` input.

### Package info

```bash
./scripts/update -i <attrpath>               # show package info (homepage, changelog, git repo, description)
```

Looks up metadata via `lib/info.nix` for a package attribute path like `nvd` or `luaPackages.lualine-nvim`.

## Architecture

### Entry points and module discovery

Host files in `hosts/` are the entry points. Except for nix-on-droid (whose configurations are defined inline in `flakes/droid.nix`), each imports OS-level modules from the corresponding directory (`nixos/`, `darwin/`, `droid/`, `openwrt/`, `solo/`). These in turn import `common/` (cross-OS shared config, except `openwrt/` which only imports `common/my`) and use `lib.my.getModules` to auto-discover all `default.nix` files in their directory tree.

`nixos/` imports modules from external inputs (agenix for secrets, disko for partitioning); `darwin/` imports agenix. `desktop/` is imported by `nixos/` and `darwin/`, but not by `solo/`, `droid/`, or `openwrt/`.

`common/` modules are auto-discovered by `lib.my.getModules`. Each program or infrastructure concern lives in its own subdirectory with a `default.nix`. `common/default.nix` activates them via `programs.<name>.enable` flags (for programs) or equivalent enable mechanisms (for infrastructure modules). Use `ls common/` to see current modules. The only inline exception is `direnv`, configured directly in `common/default.nix` rather than a subdirectory (only two lines; not worth a separate module). `common/my/` provides user identity options and is the only common module imported by OpenWrt (which doesn't need desktop tools).

To see current modules: `ls -d common/*/ desktop/*/`.

`config.nix` holds nixpkgs configuration, used by both `pkgs/default.nix` (standalone package builds) and `common/nixpkgs/default.nix` (provides nixpkgs config to all modules). Uses `allowUnfreePredicate` with a package-name whitelist instead of blanket `allowUnfree = true`. Also sets `allowAliases = false` to filter out removed packages from nixpkgs.

### Input availability (two mechanisms)

Inputs are available through two mechanisms depending on context:

**`import ../inputs { }` (direct eval)** : Used in any module that references `inputs` inside its `imports` block (e.g. `inputs.agenix.outPath + "/modules/age.nix"`). The module system must evaluate `imports` before function arguments are resolved, so receiving `inputs` from `_module.args` (via `{ inputs, ... }`) creates a circular reference: resolving `inputs` needs `_module.args`, which depends on modules being merged, which needs `imports` first. The fix is to bind `inputs` locally via `let` instead of from function args.

Modules that use this pattern: `nixos/default.nix`, `darwin/default.nix`, `common/default.nix` (sets `_module.args.inputs` from its local binding, not function args).

**`_module.args.inputs = inputs` (module injection)** : Set in `common/default.nix`. After the module system initializes, all sub-modules receive inputs via `{ inputs, ... }` in their function arguments without importing directly. This works only for modules that do **not** reference `inputs` in their `imports` block.

Other OS types use different strategies: OpenWrt passes inputs via `_module.args` (it bypasses `common/default.nix`), while droid and solo do not pass inputs at all (they don't need them). `nixos/default.nix` and `darwin/default.nix` bind inputs locally via `let` for use in their `imports` blocks.

### lib/my.nix (module auto-discovery)

`lib/my.nix` provides:
- `getPaths` : underlying utility that finds files named `file` in immediate subdirectories of `root` (used by `getModules`/`getHmModules`)
- `getModules` : accepts a list of directories (via `concatMap`), scans each directory's immediate subdirectories for `default.nix` files
- `getHmModules` : same but for `home.nix` (currently unused)
- `mkReplaceStringsModule` : creates a module that replaces strings in an existing module file (e.g., removing unwanted packages from system-path.nix)

Nested modules like `common/lazyvim/` call `getModules` themselves from their parent `default.nix`, discovering their own sub-modules (ansible/, bash/, custom/, etc.). This recursive pattern enables deep module trees without explicit import lists.

### lib/configdiff.nix (configuration diff)

`lib/configdiff.nix` provides NixOS option-level diffing between hosts. Called by `os configdiff` (`os cd`), it:
- Deep-evaluates all options via `force()` to produce a sorted key=value listing
- Uses `evalSkipPaths` to avoid crashing on known nixpkgs-internal paths
- Supports two modes: single host (diffs against git HEAD's version of the same host) and two-host comparison
- Output uses `git diff` for consistent, colorized diff formatting
- Excludes systemd option removals to avoid `foldl'` truncation issues

### lib/update.nix (package updates)

`lib/update.nix` drives the package update system invoked by `scripts/update`. It:
- Defines per-package update instructions (fetch latest release, compute hash, write new expression)
- Supports the `--argstr list-package`, `--argstr all`, and `--argstr package` flags documented above
- Returns structured data consumed by `scripts/update` for branch/PR creation

Run `scripts/update -la` to list packages with update scripts, or `cat lib/update.nix` to see the current update logic.

### Dependency management (inputs)

This repo uses a **custom input system** rather than flake inputs for nixpkgs and other dependencies. Key files:

- `inputs/inputs.nix` : declares inputs (URLs, types as git or archive, freeze behavior for inputs that should not auto-update)
- `inputs/lock.nix` : pinned revisions/hashes (the lock file)
- `inputs/default.nix` : resolves inputs (locked by default, updates selectively via `--argstr update`); for locked git inputs with an existing store path, uses `builtins.appendContext` to avoid re-fetching
- `inputs/show.nix` : renders the lock as a table for `os ns`

`scripts/os update` (or `os u`) triggers updates by calling `nix-instantiate` with update targets and writing a new `inputs/lock.nix`. Supports `<input>=<rev>` syntax to pin specific inputs to a specific revision and exclusion syntax (`os update all -<input>`). `NIXLOCK_OVERRIDE_*` env vars can override input paths locally.

### Flake wiring

`flake.nix` is a thin wrapper that imports `flakes/default.nix`, discarding all flake inputs (`outputs = _: ...`) because the custom input system handles all dependencies. It generates `devShells`, `packages`, and `apps` for both `x86_64-linux` and `aarch64-darwin` via `lib.genAttrs`. `flakes/default.nix` aggregates:
- `flakes/nixos.nix` → `nixosConfigurations`
- `flakes/darwin.nix` → `darwinConfigurations`
- `flakes/droid.nix` → `nixOnDroidConfigurations` (includes an x86_64-linux `droid` entry for CI, since `droid-arm` is aarch64 and can't build on GitHub's x86 runners)
- `flakes/openwrt.nix` → `openwrtConfigurations`
- `flakes/solo.nix` → `soloConfigurations`

`devShells` come from `shell.nix`, which auto-discovers shells from `devshells/`. A dummy shell (`pkgs.mkShellNoCC { }`) is included as a fallback for `nixpkgs/maintainers/scripts/update.py`. `packages` come from all overlays, evaluated against an empty attrset so only overlay-defined packages (not all of nixpkgs) appear in the flake output. `apps` are assembled by `apps/default.nix`, combining hand-written wrappers from `apps/` with solo configuration packages that have `meta.mainProgram`. If two packages share the same `mainProgram`, the second uses its pname as the key instead of being dropped.

Both `nixos/default.nix` and `darwin/default.nix` inject version suffixes from input metadata (`inputs.nixpkgs.lastModifiedDate` + `shortRev`) into `system.nixos.versionSuffix` / `system.darwinVersionSuffix`, so `nixos-rebuild list-generations` shows the pinned nixpkgs date.

### Custom packages and overlays

- `pkgs/by-name/` : packages using the nixpkgs by-name convention, loaded via upstream nixpkgs' `by-name-overlay.nix`
- `pkgs/wallpapers/` : wallpaper collections, loaded via `packagesFromDirectoryRecursive` in `overlays/default.nix`
- `pkgs/python/`, `pkgs/lua/`, `pkgs/vim/` : language-specific example packages (subdirectories with `.example`-suffixed files that need renaming + overlay activation to use; the overlay loading code is commented out)
- `overlays/default.nix` : custom overrides for packages from various sources, plus a `wallpapers` attribute and agenix overlay import; also has commented-out lua, python, and vim package overlays
- `overlays/jovian.nix` : per-host overlay for Jovian/Steam Deck, used only by `hosts/jovian.nix`
- `overlays/lix.nix` : replaces packages with their Lix-built variants; currently commented out in `overlays/default.nix`

### `runCommandLocal` vs `runCommand`

`runCommandLocal` = `runCommand` + `preferLocalBuild = true` + `allowSubstitutes = false`. Use this rule:

- **`runCommandLocal`** for instantaneous derivations (sed, ln, makeWrapper, cp, echo, mkdir -- under ~0.1s). Even when a substitute exists in cache, the network round-trip costs more than just rebuilding locally.
- **`runCommand`** for derivations with real computation (ImageMagick rendering, `nps --refresh`, etc.) -- the remote builder and caches handle distribution.

To find current patterns to follow: `grep -r runCommandLocal pkgs/ --include='*.nix'` and `grep -r '\brunCommand\b' nixos/ --include='*.nix'` (the few remaining `runCommand` calls in `nixos/` are the heavy ones).

### The `scripts/os` script

The main operational script. It:
1. Auto-detects the OS type for a given hostname by checking which attrset in `flakes/default.nix` contains the hostname
2. Uses the appropriate eval target (e.g. `nixosConfigurations.<host>.config.system.build.toplevel`)
3. Handles switching with OS-specific logic (NixOS uses `switch-to-configuration`, darwin uses the activation script, etc.)
4. Supports `os deploy` for remote NixOS (via `nixos-rebuild --target-host`) and remote OpenWrt (via sysupgrade); other OS types are rejected
5. Distinguishes local vs remote builds via `FOROTHER` logic, using per-host profiles at `~/.local/state/nix/profiles/$HOSTNAME`
6. Automatically runs `nvd diff` comparing the build result against the current system after each build
7. Supports dry run mode (`os dry <cmd>`), CI mode (`os ci`), and solo variant auto-detection (checks `/nix/store` ownership and sticky bit)
8. Falls back to `rebuild()` (delegating to OS-native tools like `darwin-rebuild`, `nix-on-droid`, `nixos-rebuild`) for passthrough commands and listing generations

### linkdir module

`lib/linkdir.nix` provides a module for declarative symlink forests (similar to home-manager's `home.file`). Used by various modules to manage dotfiles and filesystem trees. It creates a store path of symlinks, then runs an activation script that reconciles the real directory with the declared state.

Key capabilities:
- **Inline text content** (`text` option): file content can be specified directly in Nix, auto-derived to a store path via `pkgs.writeText`
- **Globbing support**: source paths containing `*` trigger shell globbing, creating a directory of symlinks for all matching files
- **Old state tracking**: stores a reference to the previous symlink forest at `$realdir/.local/state/linkdir/<optionName>`, enabling cleanup of removed entries across generations
- **Safety**: the activation script never replaces real (non-symlink) files, only symlinks it previously created
- **Per-entry `enable` flag**: each file entry has an `enable` option (default true)
- **Dual consumer**: used for home directory dotfiles (`common/home`) and OpenWrt builder filesystems (`openwrt/builder`)
- **Read-only outputs**: exposes `path` and `activate` as readOnly options for consumption by other modules

### Solo variants

Solo submodules live in `solo/`; use `ls solo/` to see current ones.

**solo** : Full user environment for non-NixOS Linux. Builds from `solo/` modules and `common/`, activated via `nix-env --set` (not `nix profile`) followed by the home activation script. `solo.shell` is a wrapped shell (see `solo/zsh/default.nix`). `solo.path` is built by `solo/environment/default.nix` using `pkgs.buildEnv` from `environment.systemPackages`. `hosts/solo.nix` uses `lib.hiPrio config.solo.shell` to prioritize the solo shell over other packages.

**solo-shell** : Lightweight variant that only adds `config.solo.path` to PATH, for use with `scripts/solo-shell`. Does not include the shell in `systemPackages` to avoid infinite recursion. Imports `../solo` (the solo module directory).

**solo-single** : Same as `solo`, but for [single-user (no-daemon) Nix installations](https://nix.dev/manual/nix/latest/installation/installing-binary#single-user-installation). Adds `nix.singleUser = true` (defined by `solo/nix/default.nix`) and imports `solo.nix`. Requires `--no-daemon --no-modify-profile` flags during Nix installation.

The script auto-detects which variant to use: any hostname not found in other configuration attrsets falls through to solo. If no hostname was explicitly given and the hostname also isn't in `soloConfigurations`, it checks `/nix/store`: if owned by user and not sticky, solo-single; otherwise, solo. This means `os switch` on a non-NixOS machine just works without specifying a hostname. Passing an explicit hostname argument skips auto-detection and uses that configuration directly.

`solo/compat/default.nix` bridges the gap between NixOS modules and non-NixOS systems: it imports selected NixOS modules and stubs out NixOS-specific options to prevent evaluation errors. It also disables `common/system/default.nix` via `disabledModules` to avoid conflicts with nixpkgs NixOS modules.

### CI

GitHub Actions workflows plus a composite action:

**`host.yml`** : Builds all hosts on push (triggered by changes to `inputs/lock.nix` or `.github/workflows/host.yml`) and on manual `workflow_dispatch` (with host, OS, and debug inputs). Matrix splits Linux hosts on `ubuntu-latest` and macOS on `macos-latest`. Pushes builds to Cachix. A `summary` job appends closure sizes to `data.csv` on the `gh-pages` branch and renders a markdown table in the job summary.

**`update.yml` + `.github/workflows/update.sh`** : Automated package updates, triggered on push to `master`, cron schedule (Friday-Sunday at 10:00 UTC), or manual dispatch. Uses SSH deploy keys (not `GITHUB_TOKEN`) so that created PRs trigger downstream CI. The script lists packages from existing `update/*` branches (push) or `scripts/update -la` (cron/manual), then for each package either creates a new `update/<pkg>` branch and PR, or rebases and force-pushes an existing one if upstream changed. Force-pushes twice (once after creation, once after `--amend`) to make sure `package.yml` CI fires on the PR.

**`package.yml`** : Builds a single package. Triggers on PRs touching `pkgs/**` or `overlays/default.nix` (with head ref starting with `update/`), or on manual `workflow_dispatch` (with os choice and package input). Delegates to `.github/actions/package/`. Has a cache-based early-skip: if a package's `meta.platforms` doesn't include the current runner OS, it saves a cache key so subsequent runs skip immediately instead of setting up Nix.

**`.github/actions/package/`** : Composite action for building one package. Sets up Nix and Cachix, checks platform compatibility via `nix eval`, builds with `nix -L build -f pkgs <pkg>`, lists result tree (installs `tree` via `nix-env`). On platform mismatch, writes a skip-cache key for `package.yml`'s early-exit.

**`dependabot.yml`** (`.github/dependabot.yml`) : Weekly grouped updates for GitHub Actions dependencies across both root workflows and the composite action.
