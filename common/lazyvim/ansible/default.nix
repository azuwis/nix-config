{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.ansible;
in
{
  options.my.lazyvim.ansible = {
    enable = mkEnableOption "LazyVim ansible support";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [
      ansible-language-server
    ];

    my.neovim.treesitterParsers = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
      yaml
    ])).dependencies;

    xdg.configFile."nvim/lua/plugins/ansible.lua".source = ./spec.lua;
  };
}
