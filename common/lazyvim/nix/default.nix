{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.nix;
in
{
  options.my.lazyvim.nix = {
    enable = mkEnableOption "LazyVim nix support";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];

    my.neovim.treesitterParsers = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
      nix
    ])).dependencies;

    xdg.configFile."nvim/lua/plugins/nix.lua".source = ./spec.lua;
    xdg.configFile."nvim/snippets/nix.snippets".source = ./nix.snippets;
  };
}
