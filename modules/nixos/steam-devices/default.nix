{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.steam-devices;
in
{
  options.my.steam-devices = {
    enable = mkEnableOption (mdDoc "steam-devices");
  };

  config = mkIf cfg.enable {
    services.udev.packages = [ pkgs.steam-devices ];
  };
}
