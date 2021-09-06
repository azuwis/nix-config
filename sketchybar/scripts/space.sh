#!/bin/bash

if [ "$SELECTED" = "true" ]
then
  sketchybar -m set "$NAME" icon_highlight on
else
  sketchybar -m set "$NAME" icon_highlight off
fi

index="${NAME/space}"
json="$(yabai -m query --spaces --space "$index")"
if [ -z "$json" ]
then
  exit
fi
if [ -n "${json##*\"windows\":\[\]*}" ]
then
  sketchybar -m set "$NAME" icon "${index}°"
else
  sketchybar -m set "$NAME" icon "${index}"
fi
