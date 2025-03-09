{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib) getHmModules;
in

{
  imports = getHmModules [ ./. ];

  my.ssh-agent.enable = true;
}
