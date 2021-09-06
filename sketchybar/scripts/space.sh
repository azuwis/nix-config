#!/bin/bash

yabai -m query --spaces | jq -r '.[] | [.index, .windows[0]] | @sh' | \
  while read -r index window
  do
    if [ "$window" = "null" ]
    then
      sketchybar -m set "space${index}" icon "${index}"
    else
      sketchybar -m set "space${index}" icon "${index}°"
    fi
  done
