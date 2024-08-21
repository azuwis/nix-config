{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.custom;
in
{
  options.my.lazyvim.custom = {
    enable = mkEnableOption "LazyVim custom settings";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.excludePlugins = with pkgs.vimPlugins; [ nvim-notify ];

    my.lazyvim.extraPlugins = with pkgs.vimPlugins; [
      {
        name = "mini.surround";
        path = mini-nvim;
      }
    ];

    xdg.configFile."nvim/lua/plugins/custom.lua".source = ./spec.lua;
    xdg.configFile."nvim/lua/config".source = ./config;

    xdg.configFile."nvim/package.json".source = ./package.json;
    xdg.configFile."nvim/snippets".source = ./snippets;
  };
}
