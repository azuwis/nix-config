{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.agenix.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    ../common
  ] ++ lib.my.getModules [ ../modules/darwin ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  hm.my.zsh-ssh-agent.enable = true;
}
