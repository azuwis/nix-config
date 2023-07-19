{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  hm.my.zsh-ssh-agent.enable = true;
}
