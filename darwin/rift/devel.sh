#!/usr/bin/env bash

trap 'launchctl load -w ~/Library/LaunchAgents/org.nixos.rift.plist' SIGINT SIGTERM

dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
rift-cli execute save-layout --master
launchctl unload ~/Library/LaunchAgents/org.nixos.rift.plist
rift --restore --config $dir/config.toml
