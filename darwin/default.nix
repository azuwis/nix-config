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

  settings.registry.entries = [ "nix-darwin" ];

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
