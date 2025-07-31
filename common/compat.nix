{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../inputs;
  nixpkgs = inputs.nixpkgs.outPath;
  modulesPath = nixpkgs + "/nixos/modules/";
in

{
  imports = builtins.map (path: modulesPath + path) [
    "misc/meta.nix"
    "programs/yazi.nix"
  ];
}
