{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = inputs.lib.getHmModules [ ./. ];

  my.ssh-agent.enable = true;
}
