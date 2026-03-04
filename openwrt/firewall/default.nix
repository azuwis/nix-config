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
      # For >800Mb/s NAT, but may break SQM
      firewall."@defaults[0]".flow_offloading = "1";
      firewall."@zone[1]".forward = "DROP";
      firewall."@zone[1]".input = "DROP";
    };
  };
}
