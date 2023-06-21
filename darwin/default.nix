{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/rime
  ] ++ lib.my.getModules [ ../modules/darwin ./. ];

  hm.imports = [
    ../common/rime
  ] ++ lib.my.getHmModules [ ./. ];

  my.emacs.enable = true;
  my.firefox.enable = true;

  hm.my.alacritty.enable = true;
  hm.my.mpv.enable = true;
  hm.my.zsh-ssh-agent.enable = true;
}
