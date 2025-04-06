{ ... }@args:

let
  lib = import ./lib;
in

lib.packagesFromDirectoryRecursive {
  callPackage = file: _: import file args;
  directory = ./devshells;
}
