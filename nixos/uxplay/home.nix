{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.my.uxplay;
in
{
  options.my.uxplay = {
    enable = mkEnableOption "uxplay";
    sway = mkEnableOption "startup with sway";
    systemd = mkEnableOption "uxplay systemd user service";
    args = mkOption {
      type = types.str;
      default = "-nohold -vd vah264dec";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      home.packages = [ pkgs.uxplay ];
      wayland.windowManager.sway.config.window.commands = [
        {
          criteria = {
            instance = "^UxPlay@";
          };
          command = "fullscreen enable";
        }
      ];
    })

    (mkIf cfg.sway {
      wayland.windowManager.sway.config.startup = [ { command = "uxplay -p ${cfg.args}"; } ];
    })

    (mkIf cfg.systemd {
      systemd.user.services.uxplay = {
        Unit = {
          Description = "AirPlay Unix mirroring server";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.uxplay}/bin/uxplay -p ${cfg.args}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })
  ]);
}
