#!/usr/bin/env bash

# adb shell pm grant com.termux.nix android.permission.DUMP

while read -r head rest; do
  if [ "$head" = "mLinkProperties" ]; then
    re='\{InterfaceName: wlan0 .* DnsAddresses: \[ [^ ]*/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)[ ,]'
    if [[ ${rest} =~ $re ]]; then
      nameserver="${BASH_REMATCH[1]}"
      >&2 echo "nameserver	$nameserver"
      echo "nameserver $nameserver" >/etc/resolv.conf
    else
      >&2 echo "Use /etc/resolv.conf.default"
      cp /etc/resolv.conf.default /etc/resolv.conf
    fi
    break
  fi
done < <(/system/bin/dumpsys wifi 2>/dev/null)
