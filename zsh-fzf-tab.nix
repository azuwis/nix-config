{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    zsh-fzf-tab
  ];
  programs.zsh = {
    initExtra = ''
      # zsh-fzf-tab
      . ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
  };
}
