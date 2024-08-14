#!/usr/bin/env bash

scidns_resolv_script="@scidns_resolv_script@"
sciroute_script="@sciroute_script@"
is_on() {
  iface="$(route -n get 0.0.0.0/1 2>/dev/null | awk '/interface:/ {print $2}')"
  test "${iface:0:4}" = "utun"
}
on() {
  sudo "$scidns_resolv_script" enable
  sudo "$sciroute_script" enable
}
off() {
  sudo "$scidns_resolv_script" disable
  sudo "$sciroute_script" disable
}
status() {
  if is_on; then
    echo "on"
  else
    echo "off"
  fi
}
toggle() {
  if is_on; then
    off
  else
    on
  fi
}
action="$1"
if [ -n "$action" ]; then
  "$action"
else
  status
fi
