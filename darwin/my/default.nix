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
            "/Users/${config.my.user}"
            config.my.user
          ]
          config.environment.systemPath;
    };
  };
}
