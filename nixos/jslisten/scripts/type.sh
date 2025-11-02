#!/bin/sh

if [ "$XDG_SESSION_TYPE" = wayland ]; then
  wtype -k "$@"
elif [ "$XDG_SESSION_TYPE" = x11 ]; then
  xdotool key "$@"
fi
