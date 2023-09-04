{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.mpv;

in
{
  options.my.mpv = {
    uosc = mkEnableOption (mdDoc "uosc") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.uosc) {
    programs.mpv = {
      config = {
        osc = "no";
        osd-bar = "no";
        border = "no";
      };
      scripts = with pkgs.mpvScripts; [
        uosc
      ];
      scriptOpts.osc = { };
      scriptOpts.uosc = {
        timeline_opacity = 0.3;
        timeline_size_max = 30;
        timeline_size_max_fullscreen = 40;
      };
    };
  };
}
