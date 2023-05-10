#!/bin/bash

LABEL=ABC

if defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -qF im.rime.inputmethod.Squirrel
then
  LABEL=""
fi

sketchybar --set input label="$LABEL"
