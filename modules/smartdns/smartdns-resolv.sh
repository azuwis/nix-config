#!/bin/sh
smartdns=@smartdns@
launchd_label="@launchdLabel@"
launchd_plist="/Library/LaunchDaemons/$launchd_label.plist"
smartdns_resolv=/var/run/smartdns-resolv

start() {
  echo "Start smartdns resolv"
  iface="$(netstat -rnf inet | awk '/^default/ {print $4; exit}')"
  test -z "$iface" && exit
  service="$(networksetup -listnetworkserviceorder | sed -rn "s/.*: ([^,]+),.*$iface\).*/\1/p")"
  test -z "$service" && exit
  if [ ! -e "$smartdns_resolv" ]
  then
    echo "Set $service dnsserver to $smartdns"
    networksetup -setdnsservers "$service" "$smartdns"
  fi
  dns="$(ipconfig getoption "$iface" domain_name_server)"
  test -z "$dns" && exit
  if ! grep -qFx "nameserver $dns" "$smartdns_resolv" 2>/dev/null
  then
    echo "Write nameserver $dns to $smartdns_resolv"
    echo "nameserver $dns" > "$smartdns_resolv"
  fi
  echo "Start finished"
}

stop() {
  echo "Stop smartdns resolv"
  rm -f "$smartdns_resolv"
  networksetup -listallnetworkservices | grep -Fv '*' | while read -r service
  do
    if [ "$(networksetup -getdnsservers "$service")" = "$smartdns" ]
    then
      echo "Reset $service dnsserver"
      networksetup -setdnsservers "$service" Empty
    fi
  done
  echo "Stop finished"
}

action="$1"

case "$action" in
  enable)
    start
    launchctl load -w "$launchd_plist"
    ;;
  disable)
    stop
    launchctl unload "$launchd_plist"
    ;;
  *)
    if grep -q '^nameserver ' /var/run/resolv.conf
    then
      start
    else
      stop
    fi
    ;;
esac
