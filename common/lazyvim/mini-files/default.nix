{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.lazyvim.mini-files;
in
{
  options.programs.lazyvim.mini-files = {
    enable = mkEnableOption "LazyVim mini-files support";
  };

  config = mkIf cfg.enable {
    programs.lazyvim = {
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
