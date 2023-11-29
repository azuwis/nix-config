{ config, lib, pkgs, ... }:

{
  imports = lib.my.getModules [ ./. ];
}
