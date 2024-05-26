{
  config,
  lib,
  pkgs,
  ...
}:

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
      # Temporarily let lazyvim download neogit until important fix lands on nixpkgs
      # https://github.com/NeogitOrg/neogit/commit/70ad95be902ee69b56410a5cfc690dd03104edb3
      # neogit
    ];

    xdg.configFile."nvim/lua/plugins/neogit.lua".source = ./spec.lua;
  };
}
