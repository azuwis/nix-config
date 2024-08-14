#!/bin/sh
interface="@interface@"
local_cidr="@localCidr@"
launchd_label="@launchdLabel@"
launchd_plist="/Library/LaunchDaemons/$launchd_label.plist"

each_cidr() {
  action="$1"
  shift
  for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 1.1.1.0/24; do
    route -q -n "$action" "$cidr" "$@" 1>/dev/null 2>/dev/null
  done
  while read -r cidr; do
    route -q -n "$action" "$cidr" "$@" 1>/dev/null 2>/dev/null
  done <"$local_cidr"
}

start() {
  echo "Start sciroute"
  gateway="$(route -n get default 2>/dev/null | awk '/gateway/ {print $2}')"
  test -z "$gateway" && exit
  if [ "$(netstat -rnf inet | wc -l)" -lt 1000 ]; then
    echo "Set local cidr gateway to $gateway"
    each_cidr add "$gateway"
  else
    old_gateway="$(route -n get "$(head -n 1 "$local_cidr")" 2>/dev/null | awk '/gateway/ {print $2}')"
    if [ "$gateway" != "$old_gateway" ]; then
      echo "Change local cidr gateway to $gateway"
      each_cidr change "$gateway"
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
  each_cidr delete
  ;;
*)
  if grep -q '^nameserver ' /var/run/resolv.conf; then
    start
  else
    stop
  fi
  ;;
esac
