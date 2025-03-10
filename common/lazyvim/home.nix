{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../../lib) getModules;
in

{
  imports = getModules [ ./. ];
}
