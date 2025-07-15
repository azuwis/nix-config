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
    manga-reader = mkEnableOption "manga-reader" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.manga-reader) {
    wrappers.mpv = {
      bindings = {
        M = "script-binding toggle-reader";
      };
      scripts = with pkgs.mpvScripts; [ manga-reader ];
      scriptOpts.manga-reader = {
        auto_start = true;
        similar_height_threshold = 500;
      };
    };
  };
}
