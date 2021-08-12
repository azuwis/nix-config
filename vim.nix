{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.vim
  ];
  environment.variables = {
    EDITOR = "vim";
  };
  home-manager.users."${config.my.user}".programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
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
}
