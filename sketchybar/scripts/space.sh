#!/bin/bash

if [ "$SELECTED" = "true" ]; then
  sketchybar -m batch --set $NAME icon_highlight=on label_highlight=on
else
  sketchybar -m batch --set $NAME icon_highlight=off label_highlight=off
fi
