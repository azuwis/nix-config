{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.torrent;

in 
{
  options.my.torrent = {
    torrent-ratio = mkEnableOption (mdDoc "torrent-ratio") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.torrent-ratio) {
    my.torrent-ratio.enable = true;

    services.qbittorrent.settings = {
      BitTorrent = {
        "Session.SSRFMitigation" = false;
        "Session.ValidateHTTPSTrackerCertificate" = false;
      };
      Network = {
        "Proxy.IP" = "127.0.0.1";
        "Proxy.Port" = config.my.torrent-ratio.port;
        "Proxy.Type" = "HTTP";
      };
    };

  };
}
