#!/bin/bash

get_wifi() {
  local wifi test
  wifi=$(networksetup -getairportnetwork en0)
  read -r _ _ test WIFI_LABEL <<< "$wifi"
  if [ "$test" = "Network:" ]
  then
      WIFI_ICON="􀙇"
      WIFI_PADDING=6
  else
      WIFI_LABEL=""
      WIFI_ICON="􀙈"
      WIFI_PADDING=0
  fi
}

get_wifi

sketchybar --set wifi icon="$WIFI_ICON" icon.padding_right="$WIFI_PADDING" label="$WIFI_LABEL"
