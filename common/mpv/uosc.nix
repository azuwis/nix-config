{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wrappers.mpv;
in
{
  options.wrappers.mpv = {
    uosc = mkEnableOption "uosc" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.uosc) {
    wrappers.mpv = {
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
      scripts = with pkgs.mpvScripts; [ uosc ];
      scriptOpts.osc = { };
      scriptOpts.uosc = {
        opacity = "curtain=0,timeline=0.3";
        timeline_size = 30;
      };
    };
  };
}
