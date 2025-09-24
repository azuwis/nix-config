{
  lib ? import ../lib,
  pkgs ? import ../pkgs { },
}:

# nix run -f apps <name>
# nix run ./flakes#<name>
# nix run 'github:azuwis/nix-config?dir=flakes#<name>'
builtins.removeAttrs (lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./.;
}) [ "default" ]
