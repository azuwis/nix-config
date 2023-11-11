{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.neogit;
in
{
  options.my.lazyvim.neogit = {
    enable = mkEnableOption "LazyVim neogit";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.extraPlugins = with pkgs.vimPlugins; [
      diffview-nvim
      neogit
    ];

    xdg.configFile."nvim/lua/plugins/neogit.lua".source = ./spec.lua;
  };
}
