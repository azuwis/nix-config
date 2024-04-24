{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = lib.my.getHmModules [ ./. ];

  my.zsh-ssh-agent.enable = true;
}
