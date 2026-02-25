{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  builder.profile = "zbtlink_zbt-wg3526-16m";

  uci = {
    system.hostname = "wg3526";
  };

  wireguard.enable = true;
  uci.firewall."@zone[0]".network = [ "wg0" ];
}
