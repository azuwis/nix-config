{ config, lib, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      gcc
      nixpkgs-fmt
      rnix-lsp
      terraform-ls
      tree-sitter
      yaml-language-server
    ] ++ lib.optionals (builtins.hasAttr "stylua" pkgs) [ stylua ];
    extraConfig = ''
      runtime nvchad-init.lua
      set commentstring=#\ %s
      autocmd! FileType gitcommit exec 'norm gg' | startinsert!
    '';
    plugins = with pkgs.vimPlugins; [
      csv-vim
      vim-jsonnet
      vim-nix
    ];
    withNodeJs = false;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
