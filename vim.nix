{ config, lib, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "vim";
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-commentary lightline-vim vim-nix ];
    extraConfig = ''
      set noshowmode
      let g:lightline = {
        \ 'colorscheme': 'seoul256',
        \ }
    '';
  };
}
