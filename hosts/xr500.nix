{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  builder.profile = "netgear_xr500";
  uci.system."@system[0]".hostname = "xr500";

  ddns.enable = true;
  hass.enable = true;

  # https://openwrt.org/toh/netgear/r7800#performance_tuning
  uci.network.globals.packet_steering = "2";
  uci.network.globals.steering_flows = "128";

  wireguard.enable = true;
  uci.firewall."@zone[0]".network = [ "wg1" ];
  uci.firewall."@zone[1]".network = [ "wg0" ];

  builder.packages = [ "etherwake" ];
}
