{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkMerge mkOption types;
  cfg = config.my.rpiplay;

in {
  options.my.rpiplay = {
    enable = mkEnableOption (mdDoc "rpiplay");
    sway = mkEnableOption (mdDoc "startup with sway");
    systemd = mkEnableOption (mdDoc "rpiplay systemd user service");
    args = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      home.packages = [ pkgs.rpiplay ];
      wayland.windowManager.sway.config.window.commands = [{
        criteria = { instance = "rpiplay"; };
        command = "fullscreen enable";
      }];
    })

    (mkIf cfg.sway {
      wayland.windowManager.sway.config.startup = [{ command = "rpiplay ${cfg.args}"; }];
    })

    (mkIf cfg.systemd {
      systemd.user.services.rpiplay = {
        Unit = {
          Description = "Open-source AirPlay mirroring server";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.rpiplay}/bin/rpiplay";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })

  ]);
}
