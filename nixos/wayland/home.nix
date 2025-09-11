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
    # my.waybar.enable = mkDefault true;

    programs.chromium.commandLineArgs = [
      "--enable-wayland-ime"
      "--wayland-text-input-version=3"
    ];
  };
}
