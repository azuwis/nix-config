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
    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ../common
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  environment.systemPackages = [ inputs'.agenix.packages.default ];
}
