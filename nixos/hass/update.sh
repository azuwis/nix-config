#!/usr/bin/env sh

set -u

update_fetchgit() {
  file="$1"
  echo "Update $file"
  nix run nixpkgs#update-nix-fetchgit -- "$file"
  if git commit -m "hass: Auto update $file" "$file" 1>/dev/null
  then
    git --no-pager show
  fi
}

update_fetchgit aligenie.nix
update_fetchgit xiaomi_miot.nix
# update_fetchgit zhibot.nix
