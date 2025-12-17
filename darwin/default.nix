{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  inputs = import ../inputs;
in

{
  imports = [
    (inputs.agenix.outPath + "/modules/age.nix")
    ../common
    ../desktop
  ]
  ++ getModules [ ./. ];

  registry.entries = [ "nix-darwin" ];

  environment.systemPackages = [ pkgs.agenix ];

  programs.zsh.ssh-agent.enable = true;

  # See nix-darwin/flake.nix
  nixpkgs.source = inputs.nixpkgs.outPath;
  system.checks.verifyNixPath = lib.mkDefault false;
  # Use information from inputs to set system version suffix
  system.darwinVersionSuffix = lib.mkIf (
    inputs.nixpkgs ? lastModifiedDate && inputs.nixpkgs ? shortRev
  ) ".${lib.substring 0 8 inputs.nixpkgs.lastModifiedDate}.${inputs.nixpkgs.shortRev}";
}
