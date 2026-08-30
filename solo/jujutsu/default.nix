{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.jujutsu;
in

{
  config = lib.mkIf cfg.enable {
    environment.variables.JJ_CONFIG = config.environment.etc."jj/config.toml".source;
  };
}
