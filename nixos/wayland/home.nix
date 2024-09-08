{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.wayland;
in
{
  options.my.wayland = {
    enable = mkEnableOption "wayland";
  };

  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "monospace:pixelsize=20";
          icons-enabled = false;
          lines = 8;
          terminal = "footclient";
        };
        colors = {
          background = "2e3440ff";
          text = "d8dee9ff";
          selection = "4c566aff";
          selection-text = "e8dee9ff";
        };
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "2E3440";
        font-size = 24;
        ignore-empty-password = true;
        indicator-idle-visible = true;
        indicator-radius = 100;
        show-failed-attempts = true;
      };
    };
  };
}
