{
  inputs,
  inputs',
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
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  environment.systemPackages = [ inputs'.agenix.packages.default ];
}
