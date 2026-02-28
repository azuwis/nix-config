{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  builder.profile = "netgear_xr500";
  uci.system.hostname = "xr500";

  ddns.enable = true;
  hass.enable = true;

  wireguard.enable = true;
  uci.firewall."@zone[0]".network = [ "wg1" ];
  uci.firewall."@zone[1]".network = [ "wg0" ];

  builder.packages = [ "etherwake" ];
}
