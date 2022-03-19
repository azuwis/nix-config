{ config, lib, pkgs, ... }:

{
  services.qbittorrent.enable = true;
  services.qbittorrent.config = ''
    [BitTorrent]
    Session\DefaultSavePath=/srv/torrent
    Session\GlobalDLSpeedLimit=15000
    Session\GlobalUPSpeedLimit=3072
    Session\MaxActiveDownloads=5
    Session\MaxActiveTorrents=100
    Session\MaxActiveUploads=100
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
    WebUI\Port=8080
    WebUI\UseUPnP=false
  '';
  users.users.qbittorrent.uid = 20000;
  users.groups.qbittorrent.gid = 20000;
  users.users.${config.my.user}.extraGroups = [ config.services.qbittorrent.group ];
  networking.firewall.allowedTCPPorts = [ 8999 ];
  systemd.services.torrent-ratio = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = config.services.qbittorrent.user;
      Type = "simple";
      Restart = "always";
      ExecStart="${pkgs.torrent-ratio}/bin/torrent-ratio -v";
    };
  };
}
