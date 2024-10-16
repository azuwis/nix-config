{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.jujutsu;
in
{
  options.my.lazyvim.jujutsu = {
    enable = mkEnableOption "LazyVim jujutsu support";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.extraPlugins = with pkgs.vimPlugins; [ hunk-nvim ];

    xdg.configFile."nvim/lua/plugins/jujutsu.lua".source = ./spec.lua;
  };
}
