{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getHmModules;
in

{
  imports = getHmModules [ ./. ];
}
