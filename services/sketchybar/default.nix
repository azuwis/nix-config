{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sketchybar;

  toSpacebarConfig = opts:
    concatStringsSep "\n" (mapAttrsToList
      (p: v: "sketchybar -m config ${p} ${toString v}") opts);

  configFile = mkIf (cfg.config != {} || cfg.extraConfig != "")
    "${pkgs.writeScript "sketchybarrc" (
      (if (cfg.config != {})
       then "${toSpacebarConfig cfg.config}"
       else "")
      + optionalString (cfg.extraConfig != "") cfg.extraConfig)}";
in

{
  options = with types; {
    services.sketchybar.enable = mkOption {
      type = bool;
      default = false;
      description = "Whether to enable the sketchybar";
    };

    services.sketchybar.package = mkOption {
      type = path;
      description = "The sketchybar package to use.";
    };

    services.sketchybar.config = mkOption {
      type = attrs;
      default = {};
      example = literalExpression ''
        {
          clock_format     = "%R";
          background_color = "0xff202020";
          foreground_color = "0xffa8a8a8";
        }
      '';
      description = ''
        Key/Value pairs to pass to sketchybar's 'config' domain, via the configuration file.
      '';
    };

    services.sketchybar.extraConfig = mkOption {
      type = str;
      default = "";
      example = literalExpression ''
        echo "sketchybar config loaded..."
      '';
      description = ''
        Extra arbitrary configuration to append to the configuration file.
      '';
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.sketchybar = {
      serviceConfig.ProgramArguments = [ "${cfg.package}/bin/sketchybar" ]
                                       ++ optionals (cfg.config != {} || cfg.extraConfig != "") [ "-c" configFile ];

      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
      serviceConfig.EnvironmentVariables = {
        PATH = "${cfg.package}/bin:${config.environment.systemPath}";
      };
    };
  };
}
