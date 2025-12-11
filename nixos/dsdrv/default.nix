{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dsdrv;
in

{
  options.services.dsdrv = {
    enable = lib.mkEnableOption "dsdrv";

    package = lib.mkPackageOption pkgs "dsdrv-cemuhook" { };

    openFirewall = lib.mkEnableOption "openFirewall" // {
      default = cfg.settings.host != "127.0.0.1";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "dsdrv";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "dsdrv";
    };

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options.host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
        };

        options.port = lib.mkOption {
          type = lib.types.port;
          default = 26760;
        };

        options.extraArgs = lib.mkOption {
          type = lib.types.str;
          default = "--udp-remap-buttons";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;

    users.users = lib.optionalAttrs (cfg.user == "dsdrv") {
      dsdrv = {
        isSystemUser = true;
        group = cfg.group;
        extraGroups = [ "uinput" ];
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "dsdrv") { dsdrv = { }; };

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", OWNER="${cfg.user}"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:054C:05C4.*", OWNER="${cfg.user}"
      KERNELS=="input*", SUBSYSTEMS=="input", ATTRS{id/vendor}=="054c", ATTRS{id/product}=="05c4", OWNER="${cfg.user}"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", OWNER="${cfg.user}"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:054C:09CC.*", OWNER="${cfg.user}"
      KERNELS=="input*", SUBSYSTEMS=="input", ATTRS{id/vendor}=="054c", ATTRS{id/product}=="09cc", OWNER="${cfg.user}"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", OWNER="${cfg.user}"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:054C:0CE6.*", OWNER="${cfg.user}"
      KERNELS=="input*", SUBSYSTEMS=="input", ATTRS{id/vendor}=="054c", ATTRS{id/product}=="0ce6", OWNER="${cfg.user}"
    '';

    systemd.services.dsdrv = {
      after = [ "bluetooth.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "${cfg.user}";
        Group = "${cfg.group}";
        Restart = "on-abort";
        ExecStart = "${cfg.package}/bin/dsdrv --udp --udp-host ${cfg.settings.host} --udp-port ${toString cfg.settings.port} ${cfg.settings.extraArgs}";
      };
    };

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ 26760 ];
  };
}
