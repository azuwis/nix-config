{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.shadowsocks;
in
{
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

    services.shadowsocks.bin = mkOption {
      type = types.str;
      default = "ss-local";
      defaultText = "ss-local";
      description = "This option specifies the shadowsocks bin to use.";
    };

    services.shadowsocks.programArgs = mkOption {
      type = types.listOf types.str;
      default = [
        "${cfg.package}/bin/${cfg.bin}"
        "-c"
        "${cfg.config}"
      ];
      description = "This option specifies the shadowsocks program and args to use.";
    };

    services.shadowsocks.user = mkOption {
      type = types.str;
      default = "shadowsocks";
      defaultText = "shadowsocks";
      description = "This option specifies the shadowsocks user to use.";
    };

    services.shadowsocks.uid = mkOption {
      type = types.int;
      default = 590;
      defaultText = "590";
      description = "This option specifies the shadowsocks uid to use.";
    };

    services.shadowsocks.config = mkOption {
      type = types.path;
      default = "/etc/shadowsocks/ss-local.json";
      defaultText = "/etc/shadowsocks/ss-local.json";
      description = "This option specifies the shadowsocks config file to use.";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ];

      launchd.daemons.shadowsocks = {
        serviceConfig.ProgramArguments = [
          "/bin/sh"
          "-c"
          ''/bin/wait4path ${cfg.config} && exec "$@"''
          "--"
        ] ++ cfg.programArgs;

        serviceConfig.UserName = cfg.user;
        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
        serviceConfig.SoftResourceLimits.NumberOfFiles = 4096;
        # serviceConfig.StandardErrorPath = "/tmp/shadowsocks.log";
      };
    })

    (mkIf (cfg.enable && cfg.user != "root") {
      users.knownGroups = [ "shadowsocks" ];
      users.knownUsers = [ "shadowsocks" ];
      users.groups.shadowsocks = {
        gid = cfg.uid;
      };
      users.users.shadowsocks = {
        uid = cfg.uid;
        gid = config.users.groups.shadowsocks.gid;
        home = "/var/empty";
        shell = "/usr/bin/false";
      };
    })
  ];
}
