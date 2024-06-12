{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.sciroute;
  localCidr = ./local-cidr;
  scirouteScript = pkgs.substituteAll {
    inherit (cfg) interface;
    inherit localCidr;
    src = ./sciroute.sh;
    isExecutable = true;
    launchdLabel = config.launchd.daemons.sciroute.serviceConfig.Label;
  };
in

{
  options = {
    services.sciroute.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable sciroute.";
    };

    services.sciroute.interface = mkOption {
      type = types.str;
      default = "utun100";
    };

    services.sciroute.script = mkOption {
      type = types.path;
      default = scirouteScript;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    launchd.daemons.sciroute = mkIf cfg.enable {
      serviceConfig.ProgramArguments = [ "${scirouteScript}" ];
      serviceConfig.ThrottleInterval = 10;
      serviceConfig.WatchPaths = [ "/var/run/resolv.conf" ];
      # serviceConfig.StandardErrorPath = "/tmp/sciroute.log";
    };
  };
}
