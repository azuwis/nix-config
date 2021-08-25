{ config, lib, pkgs, ... }:

{
  launchd.user.agents.sketchybar.serviceConfig = {
    StandardErrorPath = "/tmp/sketchybar.log";
    StandardOutPath = "/tmp/sketchybar.log";
  };
  services.sketchybar.enable = true;
  services.sketchybar.package = pkgs.sketchybar;
  services.sketchybar.extraConfig = ''
    #!/bin/sh
    ############## BAR ##################
    sketchybar -m config height 24
    sketchybar -m config position top
    sketchybar -m config padding_left 10
    sketchybar -m config padding_right 10
    sketchybar -m config bar_color 0xff1e1f21

    ############## SCRIPT CACHING ############
    sketchybar -m default cache_scripts on

    ############## SPACES ###############
    sketchybar -m default icon_font "JetBrains Mono:Regular:13.0"
    sketchybar -m default icon_color 0x99ffffff
    sketchybar -m default label_font "JetBrains Mono:Regular:13.0"
    sketchybar -m default label_color 0x99ffffff
    sketchybar -m default label_padding_left 4
    sketchybar -m default icon_padding_left 16

    for i in {1..5}
    do
      sketchybar -m add component space space$i left
      sketchybar -m set space$i associated_display 1
      sketchybar -m set space$i associated_space $i
      sketchybar -m set space$i icon $i
      sketchybar -m set space$i icon_highlight_color 0xfffab402
    done
    sketchybar -m set space1 icon_padding_left 0

    sketchybar -m add item clock right
    sketchybar -m set clock update_freq 10
    sketchybar -m set clock script "sketchybar -m set clock label $(date +'%a %m-%d %H:%M')"
    sketchybar -m set clock label_padding_left 15
  '';
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
