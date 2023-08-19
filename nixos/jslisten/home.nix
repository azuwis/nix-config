{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption;
  cfg = config.my.jslisten;
  ini = pkgs.formats.ini { };

  configFile = ini.generate "jslisten.ini" cfg.settings;
  sway = config.my.sway.enable;
in
{
  options.my.jslisten = {
    enable = mkEnableOption (mdDoc "jslisten");

    settings = mkOption {
      type = ini.type;
      default = {
        # PS+L
        Left = {
          button1 = 10;
          button2 = 4;
          program = if sway then "wtype -k left &" else "xdotool key Left &";
        };
        # PS+R
        Right = {
          button1 = 10;
          button2 = 5;
          program = if sway then "wtype -k right &" else "xdotool key Right &";
        };
        # PS+ZR
        Space = {
          button1 = 10;
          button2 = 7;
          program = if sway then "wtype -k space &" else "xdotool key space &";
        };
        # PS+△
        TotK = {
          button1 = 10;
          button2 = 2;
          program = "QT_QPA_PLATFORM=xcb ${./scripts}/sway-run TotK class=yuzu yuzu -f -g $(HOME)/Games/Switch/TotK.nsp &";
        };
        # PS+○
        BotW = {
          button1 = 10;
          button2 = 1;
          program = if sway then "${./scripts}/sway-botw BotW app_id=info.cemu.Cemu cemu --fullscreen --title-id 00050000101c9300 &" else "${./scripts}/i3-botw &";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.jslisten ];

    home.file.".jslisten".source = configFile;

    wayland.windowManager.sway.config = {
      startup = [{ command = "jslisten --mode hold --loglevel notice"; }];
    };

    xsession.windowManager.i3.config = {
      startup = [{ command = "jslisten --mode hold --loglevel notice"; }];
    };
  };
}
