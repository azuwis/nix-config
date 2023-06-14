{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption optionalString types;
  cfg = config.my.torrent-ratio;
in
{
  options.my.torrent-ratio = {
    enable = mkEnableOption (mdDoc "torrent-ratio");
    nginx = mkEnableOption (mdDoc "nginx") // { default = true; };
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
    };
    port = mkOption {
      type = types.port;
      default = 8082;
    };
    conf = mkOption {
      type = types.nullOr types.path;
      default = ./torrent-ratio.yaml;
    };
    db = mkOption {
      type = types.str;
      default = "torrent-ratio.db";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.torrent-ratio = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "torrent-ratio";
        Group = "torrent-ratio";
        DynamicUser = true;
        StateDirectory = "torrent-ratio";
        WorkingDirectory = "/var/lib/torrent-ratio";
        ExecStart = "${pkgs.torrent-ratio}/bin/torrent-ratio -v -addr ${cfg.host}:${builtins.toString cfg.port} -db ${cfg.db} ${optionalString (cfg.conf != null) "-conf ${cfg.conf}"}";
        Restart = "on-failure";
      };
    };

    services.nginx.virtualHosts.torrent-ratio = mkIf cfg.nginx {
      serverName = "t.${config.my.domain}";
      onlySSL = true;
      useACMEHost = "default";
      extraConfig = ''
        ssl_client_certificate ${config.my.ca};
        ssl_verify_client on;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
        proxyWebsockets = true;
      };
    };

  };
}
