{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.redsocks2;
  configFile = pkgs.writeText "redsocks2.conf" ''
    base {
      daemon = off;
      log_debug = off;
      log_info = on;
      redirector = pf;
    }

    redsocks {
      bind = "${cfg.bind}:${toString cfg.port}";
      relay = "${cfg.relay}";
      type = socks5;
    }
  '';
in

{
  options = {
    services.redsocks2.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable redsocks2.";
    };

    services.redsocks2.package = mkOption {
      type = types.path;
      default = pkgs.redsocks2;
      defaultText = "pkgs.redsocks2";
      description = "This option specifies the redsocks2 package to use.";
    };

    services.redsocks2.bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "This option specifies the interface on which redsocks2 will listen.";
    };

    services.redsocks2.port = mkOption {
      type = types.int;
      default = 1081;
      description = "This option specifies port on which redsocks2 will listen.";
    };

    services.redsocks2.relay = mkOption {
      type = types.str;
      default = "127.0.0.1:1080";
      description = "This option specifies the ip:port on which redsocks2 will relay.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    launchd.daemons.redsocks2 = {
      serviceConfig.ProgramArguments = [
        "${cfg.package}/bin/redsocks2"
        "-c"
        "${configFile}"
      ];

      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };

    environment.etc."pf.direct".source = ./pf.direct;

    system.patches = [
      (pkgs.writeText "pf-conf.patch" ''
        --- a/etc/pf.conf
        +++ b/etc/pf.conf
        @@ -23,5 +23,8 @@
         nat-anchor "com.apple/*"
         rdr-anchor "com.apple/*"
         dummynet-anchor "com.apple/*"
        +table <direct> persist file "/etc/pf.direct"
        +rdr pass on lo0 proto tcp from any to !<direct> -> ${cfg.bind} port ${toString cfg.port}
        +pass out route-to (lo0 127.0.0.1) proto tcp from any to !<direct> 
         anchor "com.apple/*"
         load anchor "com.apple" from "/etc/pf.anchors/com.apple"
      '')
    ];
  };
}
