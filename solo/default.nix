{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
in

{
  imports = [
    ../common
  ]
  ++ getModules [ ./. ];
}
