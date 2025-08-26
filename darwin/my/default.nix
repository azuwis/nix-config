{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
in

{
  options.my = {
    systemPath = mkOption { type = types.str; };
  };
  config = {
    my = {
      systemPath =
        builtins.replaceStrings
          [
            "$HOME"
            "$USER"
          ]
          [
            config.system.primaryUserHome
            config.system.primaryUser
          ]
          config.environment.systemPath;
    };
  };
}
