#!/usr/bin/env bash

menuentry='menuentry "(.*)"'
submenu='submenu "(.*)"'

title=()
open="false"
while read -r line
do
  if [[ "$line" =~ $menuentry ]]
  then
    open="true"
    title+=("${BASH_REMATCH[1]}")
    (IFS='>'; echo "${title[*]}")
  elif [[ "$line" =~ $submenu ]]
  then
    open="true"
    title+=("${BASH_REMATCH[1]}")
  elif [[ "$line" =~ "}" ]] && [ "$open" = "true" ]
  then
    unset "title[-1]"
  fi
done </boot/grub/grub.cfg | fzf | xargs --max-lines=1 --delimiter='\n' --no-run-if-empty --verbose grub-reboot
