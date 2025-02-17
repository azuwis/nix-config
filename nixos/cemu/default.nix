{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.cemu;
in
{
  options.my.cemu = {
    enable = mkEnableOption "cemu";
  };

  config = mkIf cfg.enable {
    # cemu/sdl use hidraw to support game controller motion, after
    # https://github.com/libsdl-org/SDL/pull/7697 merged, this can be disabled
    hardware.steam-hardware.enable = true;

    environment.systemPackages = [ pkgs.cemu ];
  };
}
