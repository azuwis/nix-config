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

  wireguard.enable = true;
  uci.firewall."@zone[0]".network = [ "wg1" ];
  uci.firewall."@zone[1]".network = [ "wg0" ];

  builder.packages = [
    "dnsmasq-full" # Need nftset for policy-based routing
    "etherwake"
  ];

  files.file."etc/crontabs/root".text = "0 3 */3 * * /usr/bin/killall -HUP pppd";

  # https://openwrt.org/toh/netgear/r7800#performance_tuning
  uci.network.globals.packet_steering = "2";
  uci.network.globals.steering_flows = "128";
}
