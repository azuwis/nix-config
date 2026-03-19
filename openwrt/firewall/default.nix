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
    # https://github.com/openwrt/firewall4/blob/master/root/etc/config/firewall
    uci = {
      # For >800Mb/s NAT
      firewall."@defaults[0]".flow_offloading = "1";
      firewall."@zone[1]".forward = "DROP";
      firewall."@zone[1]".input = "DROP";
    };
  };
}
