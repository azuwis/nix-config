#!/bin/bash

if [ -n "$INFO" ]
then
  WIFI_ICON="􀙇"
  WIFI_PADDING=6
else
  WIFI_ICON="􀙈"
  WIFI_PADDING=0
fi

sketchybar --set wifi icon="$WIFI_ICON" icon.padding_right="$WIFI_PADDING" label="$INFO"
