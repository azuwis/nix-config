{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.vim;
in
{
  options.my.vim = {
    enable = mkEnableOption "vim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables.EDITOR = "vim";
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        lightline-vim
        nord-vim
        vim-commentary
        vim-fugitive
        vim-nix
      ];
      extraConfig = ''
        set bg=dark
        colorscheme nord
        set noshowmode
        let g:lightline = {
          \ 'colorscheme': 'nord',
          \ }
      '';
    };
  };
}
