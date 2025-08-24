{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs;
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  imports = builtins.map (path: modulesPath + path) [
    "/programs/command-not-found/command-not-found.nix"
    "/programs/git.nix"
    "/programs/yazi.nix"
  ];
}
