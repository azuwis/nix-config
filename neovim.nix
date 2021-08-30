{ config, lib, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      nixpkgs-fmt
      rnix-lsp
      terraform-ls
      tree-sitter
      yaml-language-server
    ];
    extraConfig = ''
      runtime nvchad-init.lua
      set commentstring=#\ %s
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];
    withNodeJs = true;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
