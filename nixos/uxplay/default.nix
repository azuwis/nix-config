{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.uxplay;

in
{
  options.my.uxplay = {
    enable = mkEnableOption (mdDoc "uxplay");
  };

  config = mkIf cfg.enable {
    hm.my.uxplay.enable = true;

    networking.firewall.allowedTCPPorts = [ 7100 7000 7001 ];
    networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish.enable = true;
      publish.userServices = true;
    };

  };
}
