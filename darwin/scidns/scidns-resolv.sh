#!/bin/sh
scidns=@scidns@
launchd_label="@launchdLabel@"
launchd_plist="/Library/LaunchDaemons/$launchd_label.plist"
scidns_resolv=/var/run/scidns-resolv

start() {
  echo "Start scidns resolv"
  iface="$(route -n get default 2>/dev/null | awk '/interface/ {print $2}')"
  test -z "$iface" && exit
  service="$(networksetup -listnetworkserviceorder | sed -rn "s/.*: ([^,]+),.*$iface\).*/\1/p")"
  test -z "$service" && exit
  if [ ! -e "$scidns_resolv" ]
  then
    echo "Set $service dnsserver to $scidns"
    networksetup -setdnsservers "$service" "$scidns"
  fi
  dns="$(ipconfig getoption "$iface" domain_name_server)"
  test -z "$dns" && exit
  if ! grep -qFx "nameserver $dns" "$scidns_resolv" 2>/dev/null
  then
    echo "Write nameserver $dns to $scidns_resolv"
    echo "nameserver $dns" > "$scidns_resolv"
  fi
  echo "Start finished"
}

stop() {
  echo "Stop scidns resolv"
  rm -f "$scidns_resolv"
  networksetup -listallnetworkservices | grep -Fv '*' | while read -r service
  do
    if [ "$(networksetup -getdnsservers "$service")" = "$scidns" ]
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
