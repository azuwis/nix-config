#!/usr/bin/env bash

IFS='-' read -r id kernel <<<"$1"

case "$id" in
054c0ce6) # dualsense
  # rightshift+f10: MangoHud cycle between presets
  exec evsieve --input "/dev/input/$kernel" persist=exit \
    --hook btn:mode btn:north exec-shell="gamefzf" \
    --hook btn:mode btn:east send-key=key:esc@kb \
    --hook btn:mode btn:west send-key=key:space@kb \
    --hook btn:mode btn:south send-key=key:enter@kb \
    --hook btn:mode btn:select send-key=key:rightshift@kb send-key=key:f10@kb \
    --hook btn:mode btn:start send-key=key:backspace@kb \
    --hook btn:mode btn:tl send-key=key:up@kb \
    --hook btn:mode btn:tr send-key=key:down@kb \
    --hook btn:mode btn:tl2 send-key=key:left@kb \
    --hook btn:mode btn:tr2 send-key=key:right@kb \
    --output @kb
  ;;
045e0800) # mskb
  exec evsieve --input "/dev/input/$kernel" persist=exit \
    --map rel:hwheel_hi_res:~150..151~ key:back:1@kb \
    --map rel:hwheel_hi_res:151~..~150 key:back:0@kb \
    --map rel:hwheel_hi_res:-150~..~-151 key:forward:1@kb \
    --map rel:hwheel_hi_res:~-151..-150~ key:forward:0@kb \
    --output @kb
  ;;
esac
