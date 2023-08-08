{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption;
  cfg = config.my.jslisten;
  ini = pkgs.formats.ini { };

  configFile = ini.generate "jslisten.ini" cfg.settings;
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
          program = "wtype -k left &";
        };
        # PS+R
        Right = {
          button1 = 10;
          button2 = 5;
          program = "wtype -k right &";
        };
        # PS+ZR
        Space = {
          button1 = 10;
          button2 = 7;
          program = "wtype -k space &";
        };
        # △+PS
        BotW = {
          button1 = 10;
          button2 = 2;
          program = "${./scripts}/botw &";
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
  };
}
