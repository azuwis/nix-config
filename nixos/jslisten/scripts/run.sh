#!/bin/sh

case "$XDG_CURRENT_DESKTOP" in
i3)
  is_app_focused() {
    [ -n "$(i3-msg -t get_tree | jq -r ".. | select(.type?) | select(.focused==true and .window_properties.class==\"$CLASS\")")" ]
  }
  firefox_toggle_play() {
    if [ "$(i3-msg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true and .fullscreen_mode==1) | .window_properties.class')" = firefox ]; then
      xdotool key space
    fi
  }
  focus() {
    app_id="$1"
    class="$2"
    if [ -z "$class" ]; then
      class="$app_id"
    fi
    swaymsg --quiet "[class=$class]" focus
  }
  ;;
niri)
  is_app_focused() {
    [ "$(niri msg --json focused-window | jq -r '.app_id')" = "$APP_ID" ]
  }
  firefox_toggle_play() {
    if [ "$(niri msg --json focused-window | jq -r '[.app_id, .layout.window_size[0], .layout.window_size[1]] | join(" ")')" = "firefox $(niri msg --json focused-output | jq -r '[.logical.width, .logical.height] | join(" ")')" ]; then
      wtype -k space
    fi
  }
  focus() {
    app_id="$1"
    id=$(niri msg --json windows | jq -r "[.[] | select(.app_id==\"$app_id\")][0].id // empty")
    if [ -n "$id" ]; then
      niri msg action focus-window --id "$id"
    else
      false
    fi
  }
  ;;
sway)
  is_app_focused() {
    [ -n "$(swaymsg -t get_tree | jq -r ".. | select(.type?) | select(.focused==true and (.app_id==\"$APP_ID\" or .window_properties.class==\"$CLASS\"))")" ]
  }
  firefox_toggle_play() {
    if [ "$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true and .fullscreen_mode==1) | .app_id // .window_properties.class')" = firefox ]; then
      wtype -k space
    fi
  }
  focus() {
    app_id="$1"
    class="$2"
    if [ -z "$class" ]; then
      class="$app_id"
    fi
    swaymsg --quiet "[app_id=$app_id]" focus ||
      swaymsg --quiet "[class=$class]" focus
  }
  ;;
esac

# Implement using wlrctl, unfortunately wlrctl crash when `wlrctl window focus firefox` if firefox fullscreen
# run() {
#   if wlrctl window find "app_id:$APP_ID" state:active; then
#     wlrctl window focus firefox &&
#       wlrctl window find firefox state:active state:fullscreen &&
#       wlrctl keyboard type " "
#   else
#     wlrctl window find firefox state:active state:fullscreen &&
#       wlrctl keyboard type " "
#     wlrctl window focus "$app_id:$APP_ID" || eval "$CMD"
#   fi
# }

run() {
  if is_app_focused; then
    focus firefox && firefox_toggle_play
  else
    firefox_toggle_play
    focus "$APP_ID" "$CLASS" || eval "$CMD"
  fi
}

if command -v "${CMD%% *}" >/dev/null; then
  run
else
  APP_ID=com.moonlight_stream.Moonlight CLASS=Moonlight CMD="moonlight stream aor \"$APP\"" run
fi
