{ config, lib, pkgs, ... }:

{
  programs.adb.enable = true;
  users.users.${config.my.user}.extraGroups = [ "adbusers" ];
  environment.systemPackages = [ pkgs.android-file-transfer ];
}
