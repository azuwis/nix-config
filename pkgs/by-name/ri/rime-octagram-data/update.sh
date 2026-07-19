#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix

# shellcheck shell=bash

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

echoerr() { echo "$@" >&2; }

version=$(curl -sS https://api.github.com/repos/lotem/rime-octagram-data/releases/latest | jq -r .tag_name)
oldVersion=$(jq -r .version sources.json)

if [ -z "$version" ]; then
  echoerr "Failed to get latest version from GitHub."
  exit 1
fi

if [ "$oldVersion" = "$version" ]; then
  echoerr "Already up to date."
  exit 0
fi

echoerr "Updating $oldVersion -> $version"

jq -r '.variants | keys[]' sources.json | while IFS= read -r variant; do
  url="https://github.com/lotem/rime-octagram-data/releases/download/$version/$variant.gram"
  hash=$(nix-prefetch-url "$url") || {
    echoerr "Failed to fetch $url"
    exit 1
  }
  printf '%s\t%s\n' "$variant" "$hash"
done | jq --arg version "$version" -Rs '
  split("\n")
  | map(select(length > 0) | split("\t"))
  | { version: $version,
      variants: reduce .[] as $item ({}; .[$item[0]] = $item[1])
    }
' >sources.json.tmp

mv sources.json.tmp sources.json

echoerr "Updated to $version"
