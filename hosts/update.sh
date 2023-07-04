#!/usr/bin/env bash

# shellcheck disable=SC2024

test -e /etc/NIXOS || exit
cd "${0%/*}" || exit
sudo nixos-generate-config --show-hardware-config > "hardware-$(hostname).nix"
