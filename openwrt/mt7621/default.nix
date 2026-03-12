{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.image.config.variant == "mt7621") {
    # >900Mb/s NAT, low CPU usage, may break SQM on wan
    uci.firewall."@defaults[0]".flow_offloading_hw = "1";

    # Workaround for mt76x2e firmware crash https://github.com/openwrt/mt76/issues/407
    # mt76x2e 0000:01:00.0: Firmware running!
    # ieee80211 phy1: Hardware restart was requested
    # XXX: Not all mt7621 devices have mt76x2e, but many have this problem,
    # let's put this in mt7621 module
    sqm.enable = true;
    uci.sqm.wifi = {
      ".type" = "queue";
      # Download for wifi interface is upload for wifi clients, result max
      # upload speed: 236 Mb/s to devices ln lan, 106 Mb/s to devices on wan,
      # softirq is the bottleneck
      download = "300000";
      enabled = "1";
      interface = "phy1-ap0";
      script = "piece_of_cake.qos";
      upload = "0";
    };
  };
}
