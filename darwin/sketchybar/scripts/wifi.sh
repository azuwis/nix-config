#!/bin/bash

get_wifi() {
  WIFI_LABEL=""
  while read -r key sep value rest; do
    if [ "$key" = SSID ] && [ "$sep" = ":" ]; then
      WIFI_LABEL="$value"
    fi
  done < <(ipconfig getsummary en0)
  if [ -n "$WIFI_LABEL" ]; then
    WIFI_ICON="󰖩"
    if [ "$WIFI_LABEL" = "<redacted>" ]; then
      WIFI_LABEL=""
      WIFI_PADDING=0
    else
      WIFI_PADDING=6
    fi
  else
    WIFI_ICON="󰖪"
    WIFI_PADDING=0
  fi
}

get_wifi

sketchybar --set wifi icon="$WIFI_ICON" icon.padding_right="$WIFI_PADDING" label="$WIFI_LABEL"
