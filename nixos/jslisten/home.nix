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
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.jslisten ];

    home.file.".jslisten".source = configFile;

    wayland.windowManager.sway.config = {
      startup = [{ command = "jslisten"; }];
    };
  };
}
