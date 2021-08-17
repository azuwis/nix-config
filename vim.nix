{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.vim
  ];
  environment.variables = {
    EDITOR = "vim";
  };
  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-commentary
        lightline-vim
        vim-nix
      ];
      extraConfig = ''
        set noshowmode
        let g:lightline = {
          \ 'colorscheme': 'seoul256',
          \ }
      '';
    };
  };
}
