{ config, lib, pkgs, ... }:

let scripts = ./scripts;

in

{
  environment.systemPackages = [ pkgs.jq ];
  # launchd.user.agents.sketchybar.serviceConfig = {
  #   StandardErrorPath = "/tmp/sketchybar.log";
  #   StandardOutPath = "/tmp/sketchybar.log";
  # };
  services.sketchybar.enable = true;
  services.sketchybar.package = pkgs.sketchybar;
  services.sketchybar.extraConfig = ''
    #!/bin/bash

    bar_color=0xff2e3440
    icon_font="JetBrains Mono:Regular:13.0"
    icon_color=0xbbd8dee9
    icon_highlight_color=0xffebcb8b
    label_font="$icon_font"
    label_color="$icon_color"
    label_highlight_color="$icon_highlight_color"

    spaces=()
    for i in {1..8}
    do
        spaces+=(--add component space space$i left \
          --set space$i associated_display=1 associated_space=$i icon=$i script=${scripts}/space.sh)
    done

    sketchybar -m batch \
      --config \
        height=24 \
        position=top \
        padding_left=10 \
        padding_right=10 \
        bar_color="$bar_color" \
      --default \
        cache_scripts=on \
        icon_font="$icon_font" \
        icon_color="$icon_color" \
        icon_highlight_color="$icon_highlight_color" \
        label_font="$label_font" \
        label_color="$label_color" \
        label_highlight_color="$label_highlight_color" \
        icon_padding_left=10 \
        icon_padding_right=6 \
      --add item clock right \
      --set clock update_freq=10 script="${scripts}/status.sh" icon_padding_left=2 \
      --add item battery right \
      --set battery update_freq=60 script="${scripts}/battery.sh" \
      --add item wifi right \
      --set wifi click_script "${scripts}/click-wifi.sh" \
      --add item load right \
      --set load icon="􀍽" script="${scripts}/window-indicator.sh" \
      --subscribe load space_change \
      --add item network right \
      --default \
        icon_padding_left=0 \
        icon_padding_right=2 \
        label_padding_right=16 \
      "''${spaces[@]}"

    sketchybar -m update

    # ram disk
    cache="$HOME/.cache/sketchybar"
    mkdir -p "$cache"
    if ! mount | grep -qF "$cache"
    then
      disk=$(hdiutil attach -nobrowse -nomount ram://1024)
      disk="''${disk%% *}"
      newfs_hfs -v sketchybar "$disk"
      mount -t hfs -o nobrowse "$disk" "$cache"
    fi
  '';
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
