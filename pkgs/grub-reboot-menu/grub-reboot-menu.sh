#!/usr/bin/env bash

menuentry="menuentry [\"'](.*)[\"']"
submenu="submenu [\"'](.*)[\"']"

id=()
title=()
open="false"
last="-1"
while read -r line
do
  if [[ "$line" =~ $menuentry ]]
  then
    open="true"
    id+=("$((last+1))")
    title+=("${BASH_REMATCH[1]}")
    (IFS='>'; echo "${id[*]} ${title[*]}")
  elif [[ "$line" =~ $submenu ]]
  then
    open="true"
    id+=("$((last+1))")
    last="-1"
    title+=("${BASH_REMATCH[1]}")
  elif [[ "$line" =~ "}" ]] && [ "$open" = "true" ]
  then
    last="${id[-1]}"
    unset "id[-1]"
    unset "title[-1]"
  fi
done </boot/grub/grub.cfg | fzf --bind 'enter:become(echo {1})' | xargs --max-lines=1 --delimiter='\n' --no-run-if-empty --verbose grub-reboot
