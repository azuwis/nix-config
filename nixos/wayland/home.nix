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
  };
}
