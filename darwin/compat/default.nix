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
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/development/replace-modules.section.md
  # zsh module from nix-darwin are outdated, use the one from nixos
  disabledModules = [ "programs/zsh" ];

  imports = builtins.map (path: modulesPath + path) [
    "/programs/command-not-found/command-not-found.nix"
    "/programs/firefox.nix"
    "/programs/git.nix"
    "/programs/yazi.nix"
    "/programs/zsh/zsh.nix"
  ];
}
