{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption mkPackageOption optionalAttrs types;
  cfg = config.my.evdevhook;
  json = pkgs.formats.json { };

  configFile = json.generate "evdevhook.json" cfg.settings;

in
{
  options.my.evdevhook = {
    enable = mkEnableOption "evdevhook";

    package = mkPackageOption pkgs "evdevhook" { };

    user = mkOption {
      type = types.str;
      default = "evdevhook";
    };

    group = mkOption {
      type = types.str;
      default = "evdevhook";
    };

    settings = mkOption {
      type = json.type;
      default = {
        profiles = {
          Playstation = {
            accel = "x-y-z-";
            gyro = "x+y-z-";
          };
        };
        devices = [
          {
            name = "DualSense Wireless Controller Motion Sensors";
            profile = "Playstation";
          }
          {
            name = "Sony Interactive Entertainment DualSense Wireless Controller Motion Sensors";
            profile = "Playstation";
          }
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.user == "evdevhook") {
      evdevhook = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = optionalAttrs (cfg.group == "evdevhook") {
      evdevhook = { };
    };

    services.udev.extraRules = ''
      ATTRS{name}=="DualSense Wireless Controller Motion Sensors", OWNER="${cfg.user}"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Motion Sensors", OWNER="${cfg.user}"
    '';

    systemd.services.evdevhook = {
      after = [ "bluetooth.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "${cfg.user}";
        Group = "${cfg.group}";
        Restart = "on-abort";
        ExecStart = "${cfg.package}/bin/evdevhook ${configFile}";
      };
    };

    networking.firewall.allowedUDPPorts = [ 26760 ];

  };
}
