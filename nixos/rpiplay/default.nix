{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.rpiplay;

in {
  options.my.rpiplay = {
    enable = mkEnableOption (mdDoc "rpiplay");
  };

  config = mkIf cfg.enable {
    hm.my.rpiplay.enable = true;

    networking.firewall.allowedTCPPorts = [ 7000 7100 ];
    networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];

    services.avahi = {
      enable = true;
      nssmdns = true;
      publish.enable = true;
      publish.userServices = true;
    };

  };
}
