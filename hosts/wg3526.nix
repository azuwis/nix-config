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
    wireless.radio0.disabled = "1";
    wireless.radio1.channel = "149";
    wireless.radio1.country = "CN";
    wireless.radio1.htmode = "VHT80";
  };

  wireguard.enable = true;
  uci.firewall."@zone[0]".network = [ "wg0" ];
}
