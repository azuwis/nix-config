#!/bin/sh
interface="@interface@"
local_cidr="@localCidr@"
launchd_label="@launchdLabel@"
launchd_plist="/Library/LaunchDaemons/$launchd_label.plist"

start() {
  echo "Start sciroute"
  gateway="$(route -n get default 2>/dev/null | awk '/gateway/ {print $2}')"
  test -z "$gateway" && exit
  if [ "$(netstat -rnf inet | wc -l)" -lt 1000 ]
  then
    echo "Set local cidr gateway to $gateway"
    while read -r cidr
    do
      route -q -n add "$cidr" "$gateway" 1>/dev/null 2>/dev/null
    done < "$local_cidr"
  else
    old_gateway="$(route -n get "$(head -n 1 "$local_cidr")" 2>/dev/null | awk '/gateway/ {print $2}')"
    if [ "$gateway" != "$old_gateway" ]
    then
      echo "Change local cidr gateway to $gateway"
      while read -r cidr
      do
        route -q -n change "$cidr" "$gateway" 1>/dev/null 2>/dev/null
      done < "$local_cidr"
    fi
  fi
  route -n add 0.0.0.0/1 -interface "$interface"
  route -n add 128.0.0.0/1 -interface "$interface"
  echo "Start finished"
}

stop() {
  echo "Stop sciroute"
  route -n delete 0.0.0.0/1
  route -n delete 128.0.0.0/1
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
    while read -r cidr
    do
      route -q -n delete "$cidr" 1>/dev/null 2>/dev/null
    done < "$local_cidr"
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
