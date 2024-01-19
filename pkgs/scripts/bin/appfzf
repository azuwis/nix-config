#!/usr/bin/env bash

shopt -s nullglob

apps=( ~/Applications/*.app ~/Applications/*/*.app /Applications/*.app /Applications/*/*.app /System/Applications/*.app /System/Applications/*/*.app "$HOME"/.nix-profile/bin/* /etc/profiles/per-user/"$USER"/bin/* )
apps=( "${apps[@]%.app}" )

app=$(printf '%s\n' "${apps[@]}" | fzf --history="$HOME/.cache/appfzf" --reverse --no-info --delimiter='/' --with-nth=-1 "$@")

[[ -n "$app" ]] || exit 0;

if [[ "$app" == "/etc/profiles/per-user/$USER/bin/"* ]] || [[ "$app" == "$HOME/.nix-profile/bin/"* ]]
then
  daemon "$app"
else
  open -a "$app.app"
fi
