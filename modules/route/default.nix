{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.route;
  localCidr = ./local-cidr;
  routeScript = pkgs.substituteAll {
    inherit (cfg) interface;
    inherit localCidr;
    src = ./route.sh;
    isExecutable = true;
    launchdLabel = config.launchd.daemons.route.serviceConfig.Label;
  };
in

{
  options = {
    services.route.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable route.";
    };

    services.route.interface = mkOption {
      type = types.str;
      default = "utun99";
    };

    services.route.script = mkOption {
      type = types.path;
      default = routeScript;
      readOnly = true;
    };

  };

  config = mkIf cfg.enable {
    launchd.daemons.route = mkIf cfg.enable {
      serviceConfig.ProgramArguments = [
        "${routeScript}"
      ];
      serviceConfig.ThrottleInterval = 10;
      serviceConfig.WatchPaths = [
        "/var/run/resolv.conf"
      ];
      # serviceConfig.StandardErrorPath = "/tmp/route.log";
    };
  };
}
