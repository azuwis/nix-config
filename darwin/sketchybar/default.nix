{ config, lib, pkgs, ... }:

let scripts = ./scripts;

in

{
  environment.systemPackages = [ pkgs.jq ];
  launchd.user.agents.sketchybar.serviceConfig.EnvironmentVariables.PATH =
    lib.mkForce "${config.services.sketchybar.package}/bin:${config.my.systemPath}";
  # launchd.user.agents.sketchybar.serviceConfig = {
  #   StandardErrorPath = "/tmp/sketchybar.log";
  #   StandardOutPath = "/tmp/sketchybar.log";
  # };
  services.sketchybar.enable = true;
  services.sketchybar.package = pkgs.sketchybar;
  services.sketchybar.config = ''
    #!/bin/bash

    bar_color=0xff2e3440
    icon_font="JetBrains Mono:Medium:13.0"
    icon_color=0xbbd8dee9
    icon_highlight_color=0xffebcb8b
    label_font="$icon_font"
    label_color="$icon_color"
    label_highlight_color="$icon_highlight_color"

    spaces=()
    for i in {1..8}
    do
        spaces+=(--add space space$i left \
          --set space$i \
            associated_display=1 \
            associated_space=$i \
            icon=$i \
            click_script="yabai -m space --focus $i" \
            script=${scripts}/space.sh)
    done

    sketchybar -m \
      --bar \
        height=24 \
        position=top \
        padding_left=10 \
        padding_right=10 \
        color="$bar_color" \
      --default \
        cache_scripts=on \
        icon.font="$icon_font" \
        icon.color="$icon_color" \
        icon.highlight_color="$icon_highlight_color" \
        label.font="$label_font" \
        label.color="$label_color" \
        label.highlight_color="$label_highlight_color" \
        icon.padding_left=10 \
        icon.padding_right=6 \
      --add item clock right \
      --set clock update_freq=10 script="${scripts}/status.sh" icon.padding_left=2 \
      --add item battery right \
      --set battery update_freq=60 script="${scripts}/battery.sh" \
      --add item wifi right \
      --set wifi click_script="${scripts}/click-wifi.sh" \
      --add item load right \
      --set load icon="􀍽" script="${scripts}/window-indicator.sh" \
      --subscribe load space_change \
      --add item network right \
      --add item input right \
      --add event input_change 'AppleSelectedInputSourcesChangedNotification' \
      --subscribe input input_change \
      --set input script="${scripts}/input.sh" label.padding_right=-8 \
      --default \
        icon.padding_left=0 \
        icon.padding_right=2 \
        label.padding_right=16 \
      "''${spaces[@]}"

    sketchybar -m --update

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
