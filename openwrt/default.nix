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
  imports = getModules [ ./. ];

  config = {
    ipv6.enable = false;
  };
}
