{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.git;
in

{
  config = lib.mkIf cfg.enable {
    environment.variables.GIT_CONFIG_GLOBAL = config.environment.etc.gitconfig.source;
  };
}
