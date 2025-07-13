{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.less;
in
{
  options.my.less = {
    enable = mkEnableOption "less" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.LESS = "-RX#5";
    environment.sessionVariables.PAGER = "less -FRX#5";
  };
}
