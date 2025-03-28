#!/bin/bash

args=()

while read -r index window; do
  if [ "$window" = "null" ]; then
    args+=(--set "space${index}" label=)
  else
    args+=(--set "space${index}" label="°")
  fi
done < <(yabai -m query --spaces index,windows | jq -r '.[] | [.index, .windows[0]] | @sh')

sketchybar -m "${args[@]}"
