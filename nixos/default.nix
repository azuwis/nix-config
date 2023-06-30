{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../common
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];
}
