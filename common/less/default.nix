{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.less;
in
{
  config = lib.mkIf cfg.enable {
    environment.variables.PAGER = "less";
    programs.less.envVariables.LESS = "-FRX#5";
  };
}
