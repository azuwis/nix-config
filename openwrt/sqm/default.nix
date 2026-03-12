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
      # ip-tiny and tc-tiny does not get installed with nix-openwrt-imagebuilder, bug?
      "ip-tiny"
      "tc-tiny"
    ];
    uci.sqm = {
      eth1.".type" = "-";
    };
  };
}
