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
      bindings = {
        "<" = "script-binding uosc/prev";
        ">" = "script-binding uosc/next";
        m = "script-binding uosc/menu";
        o = "script-binding uosc/open-file";
        p = "script-binding uosc/items";
      };
      config = {
        border = "no";
        osc = "no";
        osd-bar = "no";
        osd-font-provider = "fontconfig";
      };
      scripts = with pkgs.mpvScripts; [
        uosc
      ];
      scriptOpts.osc = { };
      scriptOpts.uosc = {
        curtain_opacity = 0;
        timeline_opacity = 0.3;
        timeline_size_max = 30;
        timeline_size_max_fullscreen = 40;
      };
    };
  };
}
