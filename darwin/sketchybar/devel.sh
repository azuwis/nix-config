#!/usr/bin/env bash

trap 'launchctl load -w ~/Library/LaunchAgents/org.nixos.sketchybar.plist' SIGINT SIGTERM

dir=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
launchctl unload ~/Library/LaunchAgents/org.nixos.sketchybar.plist
nix-shell -I nixpkgs="$dir/../../pkgs" -p 'sbarlua.luaModule.withPackages(ps: [ sbarlua rift-lua ])' --run "sketchybar --config $dir/config/sketchybarrc"
