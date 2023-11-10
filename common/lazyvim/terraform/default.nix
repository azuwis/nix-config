{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.terraform;
in
{
  options.my.lazyvim.terraform = {
    enable = mkEnableOption "LazyVim terraform support";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [
      terraform-ls
    ];

    my.neovim.treesitterParsers = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
      hcl
    ])).dependencies;

    xdg.configFile."nvim/lua/plugins/terraform.lua".source = ./terraform.lua;
  };
}
