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
  imports = [ ../common/my ] ++ getModules [ ./. ];

  config = {
    ipv6.enable = false;
    system.enable = true;
  };
}
