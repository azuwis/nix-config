#!/usr/bin/env bash

lazy_plugins() {
  nvim -i NONE --headless -c ':lua for _, plugin in ipairs(require("lazy").plugins()) do if plugin.name ~= "lazy.nvim" then io.stdout:write(plugin.name .. "\n") end end' -c 'q' | sort
}

nix_plugins() {
  dir=$(awk -F'"' '/path = / {print $2}' "$(grep -o '/nix/store/[0-9a-z]\+-init.lua' "$(command -v nvim)")")
  ls -1 "$dir" | sort
}

echo "Comparing plugins provided by Nix and required by LazyVim, should output nothing:"
diff -u --label provided_by_nix <(nix_plugins) --label required_by_lazyvim <(lazy_plugins)
