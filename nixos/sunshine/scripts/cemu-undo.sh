#!/usr/bin/env bash

cd ~/.config/Cemu/ || exit

read -r audio < orig_audio
sed -i -e "s/<TVDevice>.*<\/TVDevice>/<TVDevice>$audio<\/TVDevice>/" settings.xml

cp controllerProfiles/local.xml controllerProfiles/controller0.xml
