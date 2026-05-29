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
let
  soloApps = builtins.foldl' (
    acc: package:
    let
      inherit (package.meta) mainProgram;
      pname = lib.getName package;
    in
    if builtins.hasAttr mainProgram acc then
      acc // { "${pname}" = package; }
    else
      acc // { "${mainProgram}" = package; }
  ) { } packages;
in
soloApps
// removeAttrs (lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./.;
}) [ "default" ]
