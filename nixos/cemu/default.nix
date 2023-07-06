{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.cemu;
in
{
  options.my.cemu = {
    enable = mkEnableOption (mdDoc "cemu");
  };

  config = mkIf cfg.enable {
    # cemu/sdl use hidraw to support game controller motion, after
    # https://github.com/libsdl-org/SDL/pull/7697 merged, this can be disabled
    my.steam-devices.enable = true;

    environment.systemPackages = [ pkgs.cemu ];
  };
}
