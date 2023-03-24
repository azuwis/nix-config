{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/emacs # emacs-all-the-icons-fonts
    ../common/rime
  ] ++ lib.my.getModules [ ./modules ./. ];

  hm.imports = [
    ../common/alacritty.nix
    ../common/emacs
    ../common/firefox
    ../common/mpv
    ../common/rime
    ../common/zsh-ssh-agent.nix
  ] ++ lib.my.getHmModules [ ./. ];
}
