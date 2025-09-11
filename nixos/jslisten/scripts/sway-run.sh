#!/bin/sh

run() {
  criteria="$1"
  shift
  attribute=${criteria%%=*}
  value=${criteria#*=}

  focused_json=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true)')
  if [ "$(echo "$focused_json" | jq -r ".$attribute")" = "$value" ]; then
    swaymsg --quiet '[app_id=firefox]' focus ||
      swaymsg --quiet '[class=firefox]' focus &&
      [ "$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.app_id=="firefix" or .window_properties.class=="firefox").fullscreen_mode')" = 1 ] &&
      wtype -k space
  else
    [ "$(echo "$focused_json" | jq -r '.app_id // .window_properties.class')" = firefox ] &&
      [ "$(echo "$focused_json" | jq -r '.fullscreen_mode')" = 1 ] &&
      wtype -k space
    swaymsg --quiet "[$criteria]" focus || {
      "$@"
    }
  fi
}

moonlight_app="$1"
shift

if command -v "$2" >/dev/null; then
  run "$@"
else
  run app_id=com.moonlight_stream.Moonlight moonlight stream aor "$moonlight_app"
fi
