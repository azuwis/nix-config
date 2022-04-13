{ config, lib, pkgs, ... }:

{
  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    openFirewall = true;
  };
}
