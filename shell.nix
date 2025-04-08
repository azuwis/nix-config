{ ... }@args:

let
  lib = import ./lib;
in

# nix-shell -A <name>
# nix develop ./flakes#<name>
# nix-shell --option tarball-ttl 1 https://github.com/azuwis/nix-config/archive/refs/heads/master.zip -A <name>
# nix develop 'github:azuwis/nix-config?dir=flakes#<name>'
lib.packagesFromDirectoryRecursive {
  callPackage = file: _: import file args;
  directory = ./devshells;
}
