#!/bin/sh

run() {
  class=$1
  shift

  focused=$(i3-msg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true).window_properties.class')
  if [ "$focused" = "$class" ]; then
    i3-msg --quiet '[class=firefox]' focus
    xdotool key space
  else
    if [ "$focused" = firefox ]; then
      xdotool key space
    fi
    i3-msg --quiet "[class=$class]" focus || {
      dualsensectl trigger right feedback 5 8
      "$@"
    }
  fi
}

if command -v moonlight >/dev/null; then
  run Moonlight moonlight stream aor BotW
else
  run Cemu cemu --fullscreen --title-id 00050000101c9300
fi
