{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cemu;
in
{
  options.programs.cemu = {
    enable = lib.mkEnableOption "cemu";
  };

  config = lib.mkIf cfg.enable {
    # Cemu/SDL use hidraw to support game controller motion sensor, some
    # controlers like dualsense provide evdev motion events, and don't need
    # hidraw access, but need specific kernel modules and a newer SDL version
    # https://github.com/libsdl-org/SDL/pull/7697
    #
    # Many controllers don't have evdev motion events, better to enable hidraw
    # access https://github.com/libsdl-org/SDL/tree/main/src/joystick/hidapi
    hardware.steam-hardware.enable = true;

    environment.systemPackages = [ pkgs.cemu ];
  };
}
