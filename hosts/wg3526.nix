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

  # >900Mb/s NAT, low CPU usage, may break SQM on wan
  uci.firewall."@defaults[0]".flow_offloading_hw = "1";

  # Workaround for mt76x2e firmware crash https://github.com/openwrt/mt76/issues/407
  # mt76x2e 0000:01:00.0: Firmware running!
  # ieee80211 phy1: Hardware restart was requested
  sqm.enable = true;
  uci.sqm.wifi = {
    ".type" = "queue";
    # Download for wifi interface is upload for wifi clients, result max
    # upload speed: 270 Mb/s to devices ln lan, 116 Mb/s to devices on wan,
    # softirq is the bottleneck
    download = "300000";
    enabled = "1";
    interface = "phy1-ap0";
    script = "simplest.qos";
    upload = "0";
  };
}
