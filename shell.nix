{ ... }@args:

let
  lib = import ./lib;
  pkgs = import ./pkgs { };
in

# Provide a dummy shell for nixpkgs/maintainers/scripts/update.py, used by ./scripts/update
(if builtins ? currentSystem then pkgs.mkShellNoCC { } else { })
//
  # nix-shell -A <name>
  # nix-shell devshells/<name>.nix
  # nix-shell --option tarball-ttl 1 https://github.com/azuwis/nix-config/archive/refs/heads/master.zip -A <name>
  # nix develop .#<name>
  # nix develop github:azuwis/nix-config#<name>
  (lib.packagesFromDirectoryRecursive {
    callPackage = file: _: import file args;
    directory = ./devshells;
  })
