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
  options.programs.less = {
    enhance = lib.mkEnableOption "and enhance less";
  };

  config = lib.mkIf cfg.enhance {
    programs.less.enable = true;
    environment.variables.PAGER = "less";
    programs.less.envVariables.LESS = "-FRX#5";
  };
}
