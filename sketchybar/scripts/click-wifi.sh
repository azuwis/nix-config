#!/bin/bash

iface="en0"

status="$(networksetup -getairportpower "$iface")"
status="${status#*: }"

if [ "$status" = "On" ]
then
  sketchybar -m freeze on
  sketchybar -m set wifi icon 􀙈
  sketchybar -m set wifi icon_padding_right 0
  sketchybar -m set wifi label ""
  sketchybar -m freeze off
  networksetup -setairportpower "$iface" off
else
  sketchybar -m set wifi icon 􀙇
  networksetup -setairportpower "$iface" on
fi
