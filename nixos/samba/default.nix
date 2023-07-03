{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.samba;

in
{
  options.my.samba = {
    enable = mkEnableOption (mdDoc "samba");
  };

  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      enableNmbd = false;
      enableWinbindd = false;
      openFirewall = true;
    };
  };
}
