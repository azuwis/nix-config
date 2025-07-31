{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.yazi.settings = {
    yazi = {
      mgr.ratio = [
        1
        3
        4
      ];
      preview = {
        cache_dir = "~/.cache/yazi";
        max_height = 1200;
        max_width = 800;
      };
    };
  };
}
