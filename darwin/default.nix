{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.agenix.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    ../common
  ] ++ inputs.lib.getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  environment.systemPackages = [ pkgs.agenix ];
}
