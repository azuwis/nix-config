#!/usr/bin/env bash

lazy_plugins() {
  nvim --headless -c ':lua for _, plugin in ipairs(require("lazy").plugins()) do if plugin.name ~= "lazy.nvim" then print(plugin.name) end end' -c 'q' 2>&1 | sort
}

nix_plugins() {
  dir=$(awk -F'"' '/path = / {print $2}' "$(grep -o '/nix/store/[0-9a-z]\+-init.lua' "$(command -v nvim)")")
  ls -1 "$dir" | sort
}

diff -w -u --label nix <(nix_plugins) --label lazy <(lazy_plugins)
