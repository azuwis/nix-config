{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  inputs = import ../inputs;
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  imports =
    builtins.map (path: modulesPath + path) [
      "/programs/command-not-found/command-not-found.nix"
      "/programs/git.nix"
      "/programs/yazi.nix"
    ]
    ++ [
      (inputs.agenix.outPath + "/modules/age.nix")
      (inputs.home-manager.outPath + "/nix-darwin")
      ../common
      ../common/home-manager.nix
      ../common/nixpkgs
      ../common/registry
      ../common/system
    ]
    ++ getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  environment.systemPackages = [ pkgs.agenix ];

  programs.zsh.ssh-agent.enable = true;

  # See nix-darwin/flake.nix
  nixpkgs.source = inputs.nixpkgs.outPath;
  system.checks.verifyNixPath = lib.mkDefault false;
  # Use information from npins to set system version suffix
  system.darwinVersionSuffix =
    lib.mkIf (inputs.nixpkgs ? revision)
      ".${lib.substring 0 7 inputs.nixpkgs.revision}";
}
