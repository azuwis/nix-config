{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.yazi;
in
{
  options.my.yazi = {
    enable = mkEnableOption "yazi";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      settings = {
        mgr.ratio = [
          1
          3
          4
        ];
        preview = {
          cache_dir = "${config.xdg.cacheHome}/yazi";
          max_height = 1200;
          max_width = 800;
        };
      };
    };
  };
}
