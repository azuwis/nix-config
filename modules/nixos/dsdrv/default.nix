{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption mkPackageOptionMD optionalAttrs types;
  cfg = config.my.dsdrv;

in {
  options.my.dsdrv = {
    enable = mkEnableOption (mdDoc "dsdrv");

    package = mkPackageOptionMD pkgs [ "python3" "pkgs" "dsdrv-cemuhook" ] { };

    openFirewall = mkEnableOption (mdDoc "openFirewall") // { default = true; };

    user = mkOption {
      type = types.str;
      default = "dsdrv";
    };

    group = mkOption {
      type = types.str;
      default = "dsdrv";
    };

    settings = mkOption {
      default = {};
      type = types.submodule {
        options.host = mkOption {
          type = types.str;
          default = "127.0.0.1";
        };

        options.port = mkOption {
          type = types.port;
          default = 26760;
        };
      };
    };

  };

  config = mkIf cfg.enable {
    hardware.uinput.enable = true;

    users.users = optionalAttrs (cfg.user == "dsdrv") {
      dsdrv = {
        isSystemUser = true;
        group = cfg.group;
        extraGroups = [ "uinput" ];
      };
    };

    users.groups = optionalAttrs (cfg.group == "dsdrv") {
      dsdrv = { };
    };

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
        ExecStart = "${cfg.package}/bin/dsdrv --udp --udp-host ${cfg.settings.host} --udp-port ${builtins.toString cfg.settings.port}";
      };
    };

    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 26760 ];

  };
}

