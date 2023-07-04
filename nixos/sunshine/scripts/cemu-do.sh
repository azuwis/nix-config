#!/usr/bin/env bash

cd ~/.config/Cemu/ || exit

awk -F'<|>' '/<TVDevice>/ {print $3}' settings.xml > orig_audio
sed -i -e 's/<TVDevice>.*<\/TVDevice>/<TVDevice>sink-sunshine-stereo<\/TVDevice>/' settings.xml

cp controllerProfiles/sunshine.xml controllerProfiles/controller0.xml
