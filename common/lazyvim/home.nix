{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = inputs.lib.getModules [ ./. ];
}
