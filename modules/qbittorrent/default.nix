{ config, options, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.qbittorrent;

in {
  options.services.qbittorrent = {
    enable = mkEnableOption "qbittorrent";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent stores its data files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.qbittorrent-nox;
      defaultText = literalExpression "pkgs.qbittorrent-nox";
      description = ''
        The qBittorrent package to use.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8999;
      description = ''
        The qBittorrent port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the port in <option>services.qbittorrent.port</option>.
      '';
    };
  };

  config = mkIf cfg.enable {

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {};
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        home = cfg.dataDir;
        description = "qBittorrent Daemon user";
        isSystemUser = true;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall) [ cfg.port ];

    systemd = {
      services = {
        qbittorrent = {
          description = "qBittorrent system service";
          after = [ "network.target" ];
          path = [ cfg.package pkgs.bash ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = cfg.user;
            Group = cfg.group;
            Type = "simple";
            Restart = "on-failure";
            WorkingDirectory = cfg.dataDir;
            ExecStart="${cfg.package}/bin/qbittorrent-nox";
          };
        };
      };

      tmpfiles.rules = [ "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} -" ];
    };
  };
}
