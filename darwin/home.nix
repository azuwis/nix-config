{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = lib.my.getHmModules [ ./. ];

  my.ssh-agent.enable = true;
}
