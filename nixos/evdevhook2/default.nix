{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption mkPackageOption optionalAttrs optionalString types;
  cfg = config.my.evdevhook2;
  ini = pkgs.formats.ini { };

  configFile = ini.generate "evdevhook2.ini" cfg.settings;

in
{
  options.my.evdevhook2 = {
    enable = mkEnableOption "evdevhook2";

    package = mkPackageOption pkgs "evdevhook2" { };

    user = mkOption {
      type = types.str;
      default = "evdevhook2";
    };

    group = mkOption {
      type = types.str;
      default = "evdevhook2";
    };

    settings = mkOption {
      type = ini.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.user == "evdevhook2") {
      evdevhook2 = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = optionalAttrs (cfg.group == "evdevhook2") {
      evdevhook2 = { };
    };

    services.udev.extraRules = ''
      ATTRS{name}=="DualSense Wireless Controller Motion Sensors", OWNER="${cfg.user}"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Motion Sensors", OWNER="${cfg.user}"
    '';

    systemd.services.evdevhook2 = {
      after = [ "bluetooth.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "${cfg.user}";
        Group = "${cfg.group}";
        Restart = "on-abort";
        ExecStart = "${cfg.package}/bin/evdevhook2" +
          optionalString (cfg.settings != { }) " ${configFile}";
      };
    };

    networking.firewall.allowedUDPPorts = [ 26760 ];

  };
}
