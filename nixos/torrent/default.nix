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
  cfg = config.services.torrent;

  inherit (config.my) domain;
  # Reuse upstream's generated configFile via restartTriggers
  # XXX: assumes upstream's configFile is the only restartTrigger
  configFile = builtins.head config.systemd.services.qbittorrent.restartTriggers;
in
{
  options.services.torrent = {
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
    webuiPort = mkOption {
      type = types.port;
      default = 8080;
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
      isSystemUser = true;
    };
    users.groups.${cfg.user}.gid = cfg.uid;

    systemd.tmpfiles.rules = [
      "a+ ${config.services.qbittorrent.profileDir} - - - - u:${config.my.user}:r-x"
    ];

    services.torrent-ratio.enable = cfg.torrent-ratio;

    services.qbittorrent = {
      enable = true;
      user = cfg.user;
      group = cfg.user;
      openFirewall = true;
      # services.qbittorrent.webuiPort opens the firewall, but WebUI listens on
      # 127.0.0.1 and doesn't need it. Use my.torrent.webuiPort instead, passed
      # via serverConfig.Preferences.WebUI.Port
      webuiPort = null;
      torrentingPort = 8999;
      serverConfig = {
        BitTorrent.Session = {
          DefaultSavePath = cfg.DefaultSavePath;
          DisableAutoTMMByDefault = false;
          DisableAutoTMMTriggers = {
            CategorySavePathChanged = false;
            DefaultSavePathChanged = false;
          };
          GlobalDLSpeedLimit = 15000;
          GlobalUPSpeedLimit = 3072;
          MaxActiveDownloads = 5;
          MaxActiveTorrents = 150;
          MaxActiveUploads = 150;
          Preallocation = true;
          QueueingSystemEnabled = true;
          SSRFMitigation = !cfg.torrent-ratio;
          ValidateHTTPSTrackerCertificate = !cfg.torrent-ratio;
        };
        Network.Proxy = {
          IP = "127.0.0.1";
          Port = config.services.torrent-ratio.port;
          Type = if cfg.torrent-ratio then "HTTP" else "None";
        };
        Preferences.WebUI = {
          Address = "127.0.0.1";
          Port = cfg.webuiPort;
          CSRFProtection = !config.services.nginx.enhance;
          SessionTimeout = 86400;
          UseUPnP = false;
        };
      };
    };

    # Use crudini --merge instead of upstream install so manual changes made
    # via WebUI survive across restarts. Beware removing lines from
    # serverConfig will NOT affect qBittorrent.conf, only adding and changing
    # will do.
    systemd.services.qbittorrent.serviceConfig.ExecStartPre = lib.mkForce (
      pkgs.writeShellScript "qbittorrent-pre-start" ''
        mkdir -p "${config.services.qbittorrent.profileDir}/qBittorrent/config"
        ${lib.getExe pkgs.crudini} --merge "${config.services.qbittorrent.profileDir}/qBittorrent/config/qBittorrent.conf" < ${configFile}
      ''
    );

    services.nginx.enhance = mkDefault true;
    services.nginx.virtualHosts.torrent = {
      serverName = "q.${domain}";
      onlySSL = true;
      useACMEHost = "default";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.webuiPort}";
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
        proxyPass = "http://127.0.0.1:${toString cfg.webuiPort}";
        extraConfig = ''
          client_max_body_size 10M;
        '';
      };
    };

    services.samba.enhance = mkDefault true;
    services.samba.settings.torrent = {
      path = cfg.DefaultSavePath;
      browseable = "no";
      "valid users" = cfg.user;
    };
  };
}
