{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.torrent;

  inherit (config.my) domain;
  port = builtins.toString config.services.qbittorrent.settings.Preferences."WebUI\\Port";
in
{
  options.my.torrent = {
    enable = mkEnableOption "torrent";
    torrent-ratio = mkEnableOption "torrent-ratio" // {
      default = true;
    };
    user = mkOption {
      type = types.str;
      default = "torrent";
    };
    uid = mkOption {
      type = types.int;
      default = 20000;
    };
    DefaultSavePath = mkOption {
      type = types.path;
      default = "/srv/torrent";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      uid = cfg.uid;
      group = cfg.user;
      home = config.services.qbittorrent.dataDir;
      createHome = true;
      homeMode = "0750";
      isSystemUser = true;
    };
    users.groups.${cfg.user}.gid = cfg.uid;
    systemd.tmpfiles.rules = [
      "a+ ${config.services.qbittorrent.dataDir} - - - - u:${config.my.user}:r-x"
    ];

    my.torrent-ratio.enable = cfg.torrent-ratio;
    services.qbittorrent.enable = true;
    services.qbittorrent.user = cfg.user;
    services.qbittorrent.group = cfg.user;
    services.qbittorrent.settings = {
      BitTorrent = {
        "Session\\DefaultSavePath" = cfg.DefaultSavePath;
        "Session\\DisableAutoTMMByDefault" = false;
        "Session\\DisableAutoTMMTriggers\\CategorySavePathChanged" = false;
        "Session\\DisableAutoTMMTriggers\\DefaultSavePathChanged" = false;
        "Session\\GlobalDLSpeedLimit" = 15000;
        "Session\\GlobalUPSpeedLimit" = 3072;
        "Session\\MaxActiveDownloads" = 5;
        "Session\\MaxActiveTorrents" = 150;
        "Session\\MaxActiveUploads" = 150;
        "Session\\Preallocation" = true;
        "Session\\QueueingSystemEnabled" = true;
        "Session\\SSRFMitigation" = !cfg.torrent-ratio;
        "Session\\ValidateHTTPSTrackerCertificate" = !cfg.torrent-ratio;
      };
      Network = {
        "Proxy\\IP" = "127.0.0.1";
        "Proxy\\Port" = config.my.torrent-ratio.port;
        "Proxy\\Type" = if cfg.torrent-ratio then "HTTP" else "None";
      };
      Preferences = {
        "WebUI\\Address" = "127.0.0.1";
        "WebUI\\CSRFProtection" = !config.my.nginx.enable;
        "WebUI\\Port" = 8080;
        "WebUI\\SessionTimeout" = 86400;
        "WebUI\\UseUPnP" = false;
      };
    };

    my.nginx.enable = mkDefault true;
    services.nginx.virtualHosts.torrent = {
      serverName = "q.${domain}";
      onlySSL = true;
      useACMEHost = "default";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${port}";
        extraConfig = ''
          client_max_body_size 10M;
        '';
      };
    };

    services.nginx.virtualHosts.vuetorrent = {
      serverName = "v.${domain}";
      onlySSL = true;
      useACMEHost = "default";
      root = "${pkgs.vuetorrent}/share/vuetorrent/public";
      locations."/api" = {
        proxyPass = "http://127.0.0.1:${port}";
        extraConfig = ''
          client_max_body_size 10M;
        '';
      };
    };

    my.samba.enable = mkDefault true;
    services.samba.settings.torrent = {
      path = cfg.DefaultSavePath;
      browseable = "no";
      "valid users" = cfg.user;
    };
  };
}
