#!/bin/sh

shopt -s nullglob
enable -f "$(dirname "$(readlink -f /bin/sh)")/../lib/bash/sleep" sleep

ifaces="$(cd /sys/class/net && echo en* eth* wl*)"
interval=5

last_rx=0
last_tx=0
rate=""

readable() {
  local bytes="$1"
  local kib=$((bytes >> 10))
  if [ $kib -lt 0 ]; then
    echo "?K"
  elif [ $kib -gt 1024 ]; then
    local mib_int=$((kib >> 10))
    local mib_dec=$((kib % 1024 * 976 / 10000))
    if [ "$mib_dec" -lt 10 ]; then
      mib_dec="0${mib_dec}"
    fi
    echo "${mib_int}.${mib_dec}M"
  else
    echo "${kib}K"
  fi
}

update_rate() {
  local rx=0 tx=0 tmp_rx tmp_tx

  for iface in $ifaces; do
    read -r tmp_rx <"/sys/class/net/${iface}/statistics/rx_bytes"
    read -r tmp_tx <"/sys/class/net/${iface}/statistics/tx_bytes"
    if [ $? -ne 0 ]; then
      ifaces="$(cd /sys/class/net && echo en* eth* wl*)"
      last_rx=0
      last_tx=0
      return
    fi
    rx=$((rx + tmp_rx))
    tx=$((tx + tmp_tx))
  done

  if [ "$last_rx" -eq 0 ]; then
    rate="0K↓ 0K↑"
  else
    rate="$(readable $(((rx - last_rx) / interval)))↓ $(readable $(((tx - last_tx) / interval)))↑"
  fi
  printf "%s\n" "$rate"

  last_rx=$rx
  last_tx=$tx
  sleep $interval
}

while true; do
  update_rate
done
