{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wrappers.lazyvim.mini-files;
in
{
  options.wrappers.lazyvim.mini-files = {
    enable = mkEnableOption "LazyVim mini-files support";
  };

  config = mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPlugins = [
        {
          name = "mini.files";
          path = pkgs.vimPlugins.mini-nvim;
        }
      ];
      excludePlugins = [ pkgs.vimPlugins.neo-tree-nvim ];
      config.mini-files = ./spec.lua;
    };
  };
}
