#!/bin/bash

get_battery() {
  local battery status
  battery="$(pmset -g batt)"
  BATTERY_LABEL="${battery%\%*}"
  BATTERY_LABEL="${BATTERY_LABEL##*	}"
  read -r _ _ _ status _ <<< "$battery"
  BATTERY_HIGHLIGHT="off"
  if [ "$status" = "'AC" ]
  then
    BATTERY_ICON="󱊦"
  else
    if [ "$BATTERY_LABEL" -le 30 ]
    then
      BATTERY_ICON="󱊡"
      BATTERY_HIGHLIGHT="on"
    elif [ "$BATTERY_LABEL" -le 70 ]
    then
      BATTERY_ICON="󱊢"
    else
      BATTERY_ICON="󱊣"
    fi
  fi
}

get_battery

sketchybar -m --set battery icon="$BATTERY_ICON" icon.highlight="$BATTERY_HIGHLIGHT" label="${BATTERY_LABEL}%"
