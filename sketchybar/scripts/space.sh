#!/bin/bash

args=()
while read -r index window
do
  if [ "$window" = "null" ]
  then
    args+=(--set "space${index}" "icon=${index}")
  else
    args+=(--set "space${index}" "icon=${index}°")
  fi
done <<< "$(yabai -m query --spaces | jq -r '.[] | [.index, .windows[0]] | @sh')"

sketchybar -m batch "${args[@]}"
