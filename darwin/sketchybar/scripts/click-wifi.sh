#!/bin/bash

iface="en0"

status="$(networksetup -getairportpower "$iface")"
status="${status#*: }"

if [ "$status" = "On" ]
then
  sketchybar -m batch --set wifi icon="􀙈" icon_padding_right=0 label=""
  networksetup -setairportpower "$iface" off
else
  sketchybar -m set wifi icon "􀙇"
  networksetup -setairportpower "$iface" on
fi
