{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  builder.profile = "zbtlink_zbt-wg3526-16m";
  wireguard.enable = true;
  uci = {
    system.hostname = "wg3526";
    wireless.radio0.disabled = "1";
    wireless.radio1.channel = "149";
    wireless.radio1.country = "CN";
    wireless.radio1.htmode = "VHT80";
  };
}
