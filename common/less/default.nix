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
    environment.variables.LESS = "-RX#5";
    environment.variables.PAGER = "less -FRX#5";
  };
}
