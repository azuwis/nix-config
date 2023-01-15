{ config, lib, pkgs, ... }:

let
  user = "torrent";
  path = "/srv/torrent";
  port = "8080";
  inherit (config.my) domain;
in

{
  users.users.${user} = {
    uid = 20000;
    group = user;
    home = config.services.qbittorrent.dataDir;
    isSystemUser = true;
  };
  users.groups.${user}.gid = 20000;
  users.users.${config.my.user}.extraGroups = [ user ];
  systemd.services.qbittorrent.serviceConfig.UMask = "0007";

  services.qbittorrent.enable = true;
  services.qbittorrent.user = user;
  services.qbittorrent.group = user;
  services.qbittorrent.config = ''
    [BitTorrent]
    Session\DefaultSavePath=${path}
    Session\DisableAutoTMMByDefault=false
    Session\DisableAutoTMMTriggers\CategorySavePathChanged=false
    Session\DisableAutoTMMTriggers\DefaultSavePathChanged=false
    Session\GlobalDLSpeedLimit=15000
    Session\GlobalUPSpeedLimit=3072
    Session\MaxActiveDownloads=5
    Session\MaxActiveTorrents=150
    Session\MaxActiveUploads=150
    Session\Port=8999
    Session\Preallocation=true
    Session\QueueingSystemEnabled=true
    Session\ValidateHTTPSTrackerCertificate=false

    [Network]
    Proxy\IP=127.0.0.1
    Proxy\Port=8082
    Proxy\Type=HTTP

    [Preferences]
    WebUI\Address=127.0.0.1
    WebUI\CSRFProtection=false
    WebUI\Port=${port}
    WebUI\SessionTimeout=86400
    WebUI\UseUPnP=false
  '';
  networking.firewall.allowedTCPPorts = [ 8999 ];

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

  systemd.services.torrent-ratio = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = user;
      Type = "simple";
      Restart = "always";
      ExecStart="${pkgs.torrent-ratio}/bin/torrent-ratio -v";
    };
  };

  services.nginx.virtualHosts.torrent-ratio = {
    serverName = "t.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    extraConfig = ''
      ssl_client_certificate ${./ca.crt};
      ssl_verify_client on;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:8082";
      proxyWebsockets = true;
    };
  };
}
