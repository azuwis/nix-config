{ config, lib, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      nixpkgs-fmt
      rnix-lsp
      stylua
      terraform-ls
      tree-sitter
      yaml-language-server
    ];
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
    withNodeJs = true;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
