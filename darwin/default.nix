{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/emacs # emacs-all-the-icons-fonts
    ../common/rime
  ] ++ lib.my.getModules [ ../modules/darwin ./. ];

  hm.imports = [
    ../common/alacritty.nix
    ../common/emacs
    ../common/rime
  ] ++ lib.my.getHmModules [ ./. ];

  my.firefox.enable = true;

  hm.my.mpv.enable = true;
  hm.my.zsh-ssh-agent.enable = true;
}
