{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption;
in

{
  options = {
    documentation.man.generateCaches = mkOption { };
    environment.pathsToLink = mkOption { };
    environment.profileRelativeSessionVariables = mkOption { default = { }; };
    networking.fqdnOrHostName = mkOption { default = "droid"; };
    system.activationScripts = mkOption { };
    system.build = mkOption { };
    users.defaultUserShell = mkOption { };
  };
}
