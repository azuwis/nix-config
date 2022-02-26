{ config, lib, pkgs, ... }:

{
  homebrew.casks = [ "ubersicht" ];
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
