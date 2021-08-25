#!/bin/bash

status="$HOME/.cache/spacebar/status"

readable() {
  local bytes=$1
  local icon=$2
  local kib=$(( bytes >> 10 ))
  if [ "$kib" -lt 0 ]; then
    printf ?K%s "$icon"
  elif [ "$kib" -gt 1024 ]; then
    local mib_int=$(( kib >> 10 ))
    local mib_dec=$(( kib % 1024 * 976 / 10000 ))
    if [ "$mib_dec" -lt 10 ]; then
      mib_dec="0${mib_dec}"
    fi
    printf "%s.%sM%s" "$mib_int" "$mib_dec" "$icon"
  else
    printf "%sK%s" "$kib" "$icon"
  fi
}

wifi=$(networksetup -getairportnetwork en0)
read -r _ _ test WIFI_SSID <<< "$wifi"
if [ "$test" = "Network:" ]
then
  WIFI_ICON="􀙇"
else
  WIFI_SSID=""
  WIFI_ICON="􀙈"
fi

LOAD_AVERAGE=$(sysctl -n vm.loadavg)
read -r _ _ LOAD_AVERAGE _ <<< "$LOAD_AVERAGE"

network=$(netstat -ibn -I en0)
network="${network##*en0}"
read -r _ _ _ _ _ ibytes _ _ obytes _ <<< "${network}"
ISPEED="-1"
OSPEED="-1"
if [ -e "$status" ]
then
  read -r last_ibytes last_obytes < "$status"
  ISPEED=$(( (ibytes - last_ibytes) / 5 ))
  OSPEED=$(( (obytes - last_obytes) / 5 ))
fi
echo "$ibytes $obytes" > "$status"

readable "$ISPEED" "↓ "
readable "$OSPEED" "↑ "
echo "􀍽 $LOAD_AVERAGE $WIFI_ICON $WIFI_SSID"
