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
