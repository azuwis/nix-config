{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.lazyvim.mini-files;
in
{
  options.my.lazyvim.mini-files = {
    enable = mkEnableOption "LazyVim mini-files support";
  };

  config = mkIf cfg.enable {
    my.lazyvim.extraPlugins = with pkgs.vimPlugins; [
      {
        name = "mini.files";
        path = mini-nvim;
      }
    ];

    my.lazyvim.removedPlugins = with pkgs.vimPlugins; [ neo-tree-nvim ];

    xdg.configFile."nvim/lua/plugins/mini-files.lua".source = ./spec.lua;
  };
}
