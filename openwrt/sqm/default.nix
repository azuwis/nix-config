{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sqm;
in

{
  options.sqm = {
    enable = lib.mkEnableOption "sqm";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [
      "sqm-scripts"
    ];
    uci.sqm = {
      eth1.".type" = "-";
    };
  };
}
