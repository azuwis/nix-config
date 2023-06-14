{ config, lib, pkgs, ... }:

let
  user = "torrent";
  path = "/srv/torrent";
  port = builtins.toString config.services.qbittorrent.settings.Preferences."WebUI.Port";
  inherit (config.my) domain;
in

{
  users.users.${user} = {
    uid = 20000;
    group = user;
    home = config.services.qbittorrent.dataDir;
    createHome = true;
    isSystemUser = true;
  };
  users.groups.${user}.gid = 20000;
  systemd.tmpfiles.rules = [
    "a+ ${config.services.qbittorrent.dataDir} - - - - u:${config.my.user}:r-x"
  ];

  services.qbittorrent.enable = true;
  services.qbittorrent.user = user;
  services.qbittorrent.group = user;
  services.qbittorrent.settings = {
    BitTorrent = {
      "Session.DefaultSavePath" = path;
      "Session.DisableAutoTMMByDefault" = false;
      "Session.DisableAutoTMMTriggers.CategorySavePathChanged" = false;
      "Session.DisableAutoTMMTriggers.DefaultSavePathChanged" = false;
      "Session.GlobalDLSpeedLimit" = 15000;
      "Session.GlobalUPSpeedLimit" = 3072;
      "Session.MaxActiveDownloads" = 5;
      "Session.MaxActiveTorrents" = 150;
      "Session.MaxActiveUploads" = 150;
      "Session.Preallocation" = true;
      "Session.QueueingSystemEnabled" = true;
      "Session.SSRFMitigation" = false;
      "Session.ValidateHTTPSTrackerCertificate" = false;
    };
    Network = {
      "Proxy.IP" = "127.0.0.1";
      "Proxy.Port" = config.my.torrent-ratio.port;
      "Proxy.Type" = "HTTP";
    };
    Preferences = {
      "WebUI.Address" = "127.0.0.1";
      "WebUI.CSRFProtection" = false;
      "WebUI.Port" = 8080;
      "WebUI.SessionTimeout" = 86400;
      "WebUI.UseUPnP" = false;
    };
  };

  services.nginx.virtualHosts.torrent = {
    serverName = "q.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    locations."/".proxyPass = "http://127.0.0.1:${port}";
  };

  services.nginx.virtualHosts.vuetorrent = let
    vuetorrent = pkgs.fetchzip {
      url = "https://github.com/WDaan/VueTorrent/releases/download/v0.15.3/vuetorrent.zip";
      sha256 = "sha256-IcgGL9u+nSIBT/tebXkmqXwvCbb0Q3U1OPtVuHo9a1M=";
    };
  in {
    serverName = "v.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    root = "${vuetorrent}/public";
    locations."/api".proxyPass = "http://127.0.0.1:${port}";
  };

  services.samba.shares.torrent = {
    inherit path;
    browseable = "no";
    "valid users" = user;
  };

}
