#!/bin/bash

STATUS="$HOME/.cache/sketchybar/status"

readable() {
  local bytes=$1
  local kib=$(( bytes >> 10 ))
  if [ "$kib" -lt 0 ]; then
    printf "?K"
  elif [ "$kib" -gt 1024 ]; then
    local mib_int=$(( kib >> 10 ))
    local mib_dec=$(( kib % 1024 * 976 / 10000 ))
    if [ "$mib_dec" -lt 10 ]; then
      mib_dec="0${mib_dec}"
    fi
    printf "%s.%sM" "$mib_int" "$mib_dec"
  else
    printf "%sK" "$kib"
  fi
}

get_wifi() {
  local wifi test
  wifi=$(networksetup -getairportnetwork en0)
  read -r _ _ test WIFI_LABEL <<< "$wifi"
  if [ "$test" = "Network:" ]
  then
      WIFI_ICON="􀙇"
  else
      WIFI_LABEL=""
      WIFI_ICON="􀙈"
  fi
}

get_load() {
  local load
  load=$(sysctl -n vm.loadavg)
  read -r _ _ load _ <<< "$load"
  LOAD="$load"
}

get_network() {
  local network ibytes obytes last_ibytes last_obytes
  network=$(netstat -ibn -I en0)
  network="${network##*en0}"
  read -r _ _ _ _ _ ibytes _ _ obytes _ <<< "${network}"
  ISPEED="-1"
  OSPEED="-1"
  if [ -e "$STATUS" ]
  then
    read -r last_ibytes last_obytes < "$STATUS"
    ISPEED=$(( (ibytes - last_ibytes) / 10 ))
    OSPEED=$(( (obytes - last_obytes) / 10 ))
  fi
  echo "$ibytes $obytes" > "$STATUS"
}

get_wifi
get_load
get_network

sketchybar -m set clock label "$(date +'%a %m-%d %H:%M')"
sketchybar -m set wifi icon "$WIFI_ICON"
sketchybar -m set wifi label "$WIFI_LABEL"
if [ -z "$WIFI_LABEL" ]
then
  sketchybar -m set wifi icon_padding_right 0
else
  sketchybar -m set wifi icon_padding_right 6
fi
sketchybar -m set load label "$LOAD"
sketchybar -m set network label "$(readable "$ISPEED")↓ $(readable "$OSPEED")↑"
