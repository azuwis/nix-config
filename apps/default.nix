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
  packages = builtins.filter (
    package: package.meta ? mainProgram
  ) eval.config.environment.systemPackages;
in

# nix run -f apps <name>
# nix run .#<name>
# nix run github:azuwis/nix-config#<name>
lib.genAttrs' packages (package: lib.nameValuePair package.meta.mainProgram package)
// removeAttrs (lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./.;
}) [ "default" ]
