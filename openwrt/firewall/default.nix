{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.firewall;
in

{
  options.firewall = {
    enable = lib.mkEnableOption "firewall";
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/openwrt/openwrt/blob/main/package/network/config/firewall/files/firewall.config
    uci = {
      firewall."@defaults[0]" = {
        # For >800Mb/s NAT, but may break SQM
        flow_offloading = "1";
      }
      // lib.optionalAttrs (config.image.config.variant == "mt7621") {
        # >900Mb/s NAT, low CPU usage
        flow_offloading_hw = "1";
      };
      firewall."@zone[1]".forward = "DROP";
      firewall."@zone[1]".input = "DROP";
    };
  };
}
