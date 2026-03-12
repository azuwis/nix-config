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

  wireguard.enable = true;
  wireguard.cron = true;
  uci.firewall."@zone[0]".network = [ "wg0" ];

  builder.packages = [ "etherwake" ];
}
