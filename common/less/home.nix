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
    enable = mkEnableOption "less";
  };

  config = mkIf cfg.enable {
    home.sessionVariables.LESS = "-RX#5";
  };
}
