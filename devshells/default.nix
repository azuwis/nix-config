{ ... }@args:

let
  lib = import ../lib;
in

# nix-shell devshells -A <name>
# nix-shell devshells/<name>.nix
# nix develop .#<name>
# nix develop github:azuwis/nix-config#<name>
removeAttrs (lib.packagesFromDirectoryRecursive {
  callPackage = file: _: import file args;
  directory = ../devshells;
}) [ "default" ]
