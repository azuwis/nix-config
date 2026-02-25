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
      firewall."@zone[1]".forward = "DROP";
      firewall."@zone[1]".input = "DROP";
    };
  };
}
