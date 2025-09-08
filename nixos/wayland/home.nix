{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (config.my) scale;
  cfg = config.my.wayland;
in
{
  options.my.wayland = {
    enable = mkEnableOption "wayland";

    terminal = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    my.swayidle.enable = mkDefault true;
    # my.waybar.enable = mkDefault true;
    my.yambar.enable = mkDefault true;

    programs.chromium.commandLineArgs = [
      "--enable-wayland-ime"
      "--wayland-text-input-version=3"
    ];

    programs.swaylock = {
      enable = true;
      settings = {
        color = "2E3440";
        font-size = 24 * scale;
        ignore-empty-password = true;
        indicator-idle-visible = true;
        indicator-radius = 100;
        show-failed-attempts = true;
      };
    };
  };
}
