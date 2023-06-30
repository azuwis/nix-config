{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.desktop;

in
{
  options.my.desktop = {
    enable = mkEnableOption (mdDoc "desktop");
  };

  config = mkIf cfg.enable {
    my.mpv.enable = true;

    home.packages = with pkgs; [
      evemu
      evtest
      chromium
      python3.pkgs.subfinder
    ];

  };
}
