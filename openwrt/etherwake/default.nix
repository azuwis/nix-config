{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.etherwake;
in

{
  options.etherwake = {
    enable = lib.mkEnableOption "etherwake";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [ "etherwake" ];
    uci.etherwake."@target[0]".".type" = "-";
    uci.etherwake.setup.interface = "br-lan";
  };
}
