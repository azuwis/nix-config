{
  lib ? import ../lib,
  pkgs ? import ../pkgs { },
}:

let
  eval = lib.evalModules {
    modules = [
      ../solo
      {
        nixpkgs = {
          inherit pkgs;
          overlays = lib.mkForce [ ];
        };
      }
    ];
  };

  mkSoloPackage = name: eval.config.programs.${name}.finalPackage;
in

# nix run -f apps <name>
# nix run ./flakes#<name>
# nix run 'github:azuwis/nix-config?dir=flakes#<name>'
removeAttrs (lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./.;
}) [ "default" ]
// lib.genAttrs [
  "jujutsu"
  "lazyvim"
] mkSoloPackage
