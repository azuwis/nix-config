{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.agenix.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    ../common
  ] ++ lib.my.getModules [ ../modules/darwin ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  my.emacs.enable = true;
  my.firefox.enable = true;
  my.rime.enable = true;

  hm.my.alacritty.enable = true;
  hm.my.mpv.enable = true;
  hm.my.zsh-ssh-agent.enable = true;
}
