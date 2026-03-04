{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  builder.profile = "zbtlink_zbt-wg3526-16m";
  uci.system."@system[0]".hostname = "wg3526";

  uci.firewall."@defaults[0]".flow_offloading_hw = "1";

  wireguard.enable = true;
  uci.firewall."@zone[0]".network = [ "wg0" ];

  builder.packages = [ "etherwake" ];
}
