{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.shadowsocks;

in {
  options = {
    services.shadowsocks.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable shadowsocks.";
    };

    services.shadowsocks.package = mkOption {
      type = types.path;
      default = pkgs.shadowsocks-libev;
      defaultText = "pkgs.shadowsocks-libev";
      description = "This option specifies the shadowsocks package to use.";
    };

    services.shadowsocks.config = mkOption {
      type = types.path;
      default = "/etc/shadowsocks/ss-local.json";
      defaultText = "/etc/shadowsocks/ss-local.json";
      description = "This option specifies the shadowsocks config file to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.knownGroups = [ "shadowsocks" ];
    users.knownUsers = [ "shadowsocks" ];
    users.groups.shadowsocks = { gid = mkDefault 590; };
    users.users.shadowsocks = {
      uid = mkDefault 590;
      gid = config.users.groups.shadowsocks.gid;
      home = "/var/empty";
      shell = "/usr/bin/false";
    };

    launchd.daemons.shadowsocks = {
      serviceConfig.ProgramArguments = [
        "/bin/sh" "-c" ''/bin/wait4path /nix/store && exec "$@"'' "--"
        "${cfg.package}/bin/ss-local" "-c" "${cfg.config}"
      ];

      serviceConfig.UserName = "shadowsocks";
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
      serviceConfig.SoftResourceLimits.NumberOfFiles = 4096;
    };
  };
}
