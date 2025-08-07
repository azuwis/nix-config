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
    (inputs.home-manager.outPath + "/nix-darwin")
    ../common
    ../common/home-manager.nix
    ../common/nixpkgs
    ../common/registry
    ../common/system
  ] ++ getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  environment.systemPackages = [ pkgs.agenix ];

  # See nix-darwin/flake.nix
  nixpkgs.source = inputs.nixpkgs.outPath;
  system.checks.verifyNixPath = lib.mkDefault false;
  # Use information from npins to set system version suffix
  system.darwinVersionSuffix =
    lib.mkIf (inputs.nixpkgs ? revision)
      ".${lib.substring 0 7 inputs.nixpkgs.revision}";
}
