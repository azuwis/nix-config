#!/bin/sh
smartdns=@smartdns@
smartdns_resolv=/var/run/smartdns-resolv

enable() {
  iface="$(netstat -rnf inet | awk '/^default/ {print $4; exit}')"
  test -z "$iface" && exit
  service="$(networksetup -listnetworkserviceorder | sed -rn "s/.*: ([^,]+),.*$iface\).*/\1/p")"
  test -z "$service" && exit
  if [ ! -e "$smartdns_resolv" ]
  then
    networksetup -setdnsservers "$service" "$smartdns"
  fi
  dns="$(ipconfig getoption "$iface" domain_name_server)"
  test -z "$dns" && exit
  if ! grep -qFx "nameserver $dns" "$smartdns_resolv" 2>/dev/null
  then
    echo "nameserver $dns" > "$smartdns_resolv"
  fi
}

disable() {
  rm -f "$smartdns_resolv"
  networksetup -listallnetworkservices | grep -Fv '*' | while read -r service
  do
    if [ "$(networksetup -getdnsservers "$service")" = "$smartdns" ]
    then
      networksetup -setdnsservers "$service" Empty
    fi
  done
}

action="$1"

if [ -n "$action" ]
then
  "$action"
else
  if ! grep -q '^nameserver ' /var/run/resolv.conf
  then
    disable
  else
    enable
  fi
fi
