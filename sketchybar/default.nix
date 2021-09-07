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
    #!/bin/sh
    sketchybar -m freeze on

    # bar
    sketchybar -m batch --config height=24 position=top padding_left=10 padding_right=10 bar_color=0xff2e3440

    # scripts cache
    sketchybar -m default cache_scripts on

    # default
    sketchybar -m batch --default icon_font="JetBrains Mono:Regular:13.0" icon_color=0xbbd8dee9 icon_highlight_color=0xffebcb8b label_font="JetBrains Mono:Regular:13.0" label_color=0xbbd8dee9

    # spaces
    sketchybar -m default icon_padding_right 16
    for i in {1..8}
    do
      sketchybar -m add component space space$i left
      sketchybar -m batch --set space$i associated_display=1 associated_space=$i icon=$i
    done

    # status default
    sketchybar -m batch --default icon_padding_left=10 icon_padding_right=6

    # clock
    sketchybar -m add item clock right
    sketchybar -m batch --set clock update_freq=10 script="${scripts}/status.sh" icon_padding_left=2

    # battery
    sketchybar -m add item battery right
    sketchybar -m batch --set battery update_freq=60 script="${scripts}/battery.sh"

    # wifi
    sketchybar -m add item wifi right
    sketchybar -m set wifi click_script "${scripts}/click-wifi.sh"

    # load
    sketchybar -m add item load right
    sketchybar -m batch --set load icon="􀍽" script="${scripts}/space.sh"
    sketchybar -m subscribe load space_change

    # network
    sketchybar -m add item network right

    # end
    sketchybar -m freeze off
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
