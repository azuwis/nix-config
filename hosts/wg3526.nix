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

  my.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9x/ifv+vbaglzQ4rs3LNt39cxUkMtQSnD1uRJ8kaNS"
  ];

  wireguard.enable = true;
  wireguard.cron = true;
  uci.dhcp."@dnsmasq[0]".localservice = "0"; # Response on wg0
  uci.firewall."@zone[0]".network = [ "wg0" ];

  builder.packages = [ "etherwake" ];

  files.file."etc/hotplug.d/iface/99-wan-check".text = ''
    if [ "$ACTION" = ifup ] && [ "$INTERFACE" = wan ]; then
      RETRY_COUNT=0
      MAX_RETRIES=10
      while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
        RESULT=$(wget -q -O - http://www.baidu.com | grep -c "baidu")
        if [ "$RESULT" -ge 5 ]; then
          logger -t wan-check "Success: Found $RESULT matches"
          break
        else
          RETRY_COUNT=$((RETRY_COUNT + 1))
          logger -t wan-check "Check failed (found $RESULT). Retry $RETRY_COUNT/$MAX_RETRIES in 30s..."
          sleep 30
        fi
      done
      if [ "$RETRY_COUNT" -eq "$MAX_RETRIES" ]; then
        logger -t wan-check "Failed: Reached max $MAX_RETRIES retries"
      fi
    fi
  '';

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
