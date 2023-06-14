{ config, lib, pkgs, ... }:

let
  inherit (lib) literalExpression mkEnableOption mkIf mkOption types;
  cfg = config.services.qbittorrent;

  configFile = pkgs.writeText "qBittorrent.conf" cfg.config;

in
{
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

    config = mkOption {
      type = types.lines;
      default = "";
      example = literalExpression ''
        [BitTorrent]
        Session\Port=8999

        [Preferences]
        WebUI\Address=127.0.0.1
        WebUI\Port=8080
      '';
      description = ''
        The config to be merged into <filename>$XDG_CONFIG_HOME/qBittorrent/qBittorrent.conf</filename>.
        Beware removing lines from this option will NOT effect qBittorrent.conf, only adding and changing will do.
      '';
    };

  };

  config = mkIf cfg.enable {

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = { };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        home = cfg.dataDir;
        createHome = true;
        homeMode = "0750";
        description = "qBittorrent Daemon user";
        isSystemUser = true;
      };
    };

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
            ExecStart = "${cfg.package}/bin/qbittorrent-nox";
          };
          preStart = lib.optionalString (cfg.config != "") ''
            ${pkgs.crudini}/bin/crudini --merge ${cfg.dataDir}/.config/qBittorrent/qBittorrent.conf < ${configFile}
          '';
        };
      };

      tmpfiles.rules = [
        "d '${cfg.dataDir}/.config/qBittorrent' 0755 ${cfg.user} ${cfg.group} -"
      ];
    };
  };
}
