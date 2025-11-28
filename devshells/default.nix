{ ... }@args:

let
  lib = import ../lib;
in

# nix-shell devshells -A <name>
# nix-shell devshells/<name>.nix
# nix develop ./flakes#<name>
# nix develop 'github:azuwis/nix-config?dir=flakes#<name>'
removeAttrs (lib.packagesFromDirectoryRecursive {
  callPackage = file: _: import file args;
  directory = ../devshells;
}) [ "default" ]
