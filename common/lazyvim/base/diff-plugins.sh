#!/usr/bin/env bash

lazy_plugins() {
  nvim --headless -c ':lua for _, plugin in ipairs(require("lazy").plugins()) do print(plugin.name) end' -c 'q' 2>&1 | grep -vxF 'lazy.nvim' | sort
}

nix_plugins() {
  dir=$(awk -F'"' '/path = / {print $2}' ~/.config/nvim/init.lua)
  ls -1 "$dir" | sort
}

diff -w -u --label nix <(nix_plugins) --label lazy <(lazy_plugins)
