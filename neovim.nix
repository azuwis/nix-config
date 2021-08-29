{ config, lib, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      rnix-lsp
      terraform-ls
      tree-sitter
      yaml-language-server
    ];
    extraConfig = ''
      runtime nvchad-init.lua
    '';
    withNodeJs = true;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
