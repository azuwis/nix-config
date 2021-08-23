{ config, lib, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "vim";
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      lightline-vim
      vim-commentary
      vim-fugitive
      vim-gruvbox8
      vim-nix
    ];
    extraConfig = ''
      set bg=dark
      colorscheme gruvbox8_hard
      set noshowmode
      let g:lightline = {
        \ 'colorscheme': 'seoul256',
        \ }
    '';
  };
}
