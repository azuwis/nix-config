{ ... }:

let
  lib = import ./lib;
in

lib.packagesFromDirectoryRecursive {
  callPackage = import;
  directory = ./devshells;
}
