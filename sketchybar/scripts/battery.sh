#!/bin/bash

get_battery() {
  local battery status
  battery="$(pmset -g batt)"
  BATTERY_LABEL="${battery%\%*}"
  BATTERY_LABEL="${BATTERY_LABEL##*	}"
  read -r _ _ _ status _ <<< "$battery"
  BATTERY_ICON="􀛨"
  if [ "$status" = "'AC" ]
  then
    BATTERY_ICON="􀢋"
  fi
}

get_battery

sketchybar -m set battery icon "$BATTERY_ICON"
sketchybar -m set battery label "${BATTERY_LABEL}%"
