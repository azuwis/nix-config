#!/bin/sh
smartdns=@smartdns@
if ! grep -q '^nameserver ' /var/run/resolv.conf
then
  rm -f /var/run/smartdns-update
  networksetup -listallnetworkservices | grep -v '*' | while read -r service
  do
    if [ "$(networksetup -getdnsservers "$service")" = "$smartdns" ]
    then
      networksetup -setdnsservers "$service" Empty
    fi
  done
else
  iface="$(netstat -rnf inet | awk '/^default/ {print $4; exit}')"
  test -z "$iface" && exit
  service="$(networksetup -listnetworkserviceorder | sed -rn "s/.*: ([^,]+),.*$iface\).*/\1/p")"
  test -z "$service" && exit
  if [ ! -e /var/run/smartdns-update ]
  then
    networksetup -setdnsservers "$service" "$smartdns"
  fi
  dns="$(ipconfig getoption "$iface" domain_name_server)"
  test -z "$dns" && exit
  if ! grep -qFx "nameserver $dns" /var/run/smartdns-update 2>/dev/null
  then
    echo "nameserver $dns" > /var/run/smartdns-update
  fi
fi
