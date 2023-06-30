{ config, lib, pkgs, ... }:

{
  imports = lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];
}
