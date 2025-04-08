{
  pkgs ? import ../pkgs { },
}:

builtins.removeAttrs (pkgs.lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./.;
}) [ "default" ]
