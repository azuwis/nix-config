#!/bin/bash

if [ "$SELECTED" = "true" ]; then
  sketchybar -m --set "$NAME" icon.highlight=on label.highlight=on
else
  sketchybar -m --set "$NAME" icon.highlight=off label.highlight=off
fi
