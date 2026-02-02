{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs { };
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  imports = map (path: modulesPath + path) [
    "/programs/firefox.nix"
    "/programs/git.nix"
    "/programs/less.nix"
    "/programs/yazi.nix"
  ];
}
