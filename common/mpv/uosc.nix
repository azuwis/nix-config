{ config, lib, pkgs, ... }:

{
  programs.mpv = {
    config = {
      osc = "no";
      osd-bar = "no";
      border = "no";
      script-opts = "uosc-timeline_opacity=0.3,uosc-timeline_size_max=30,uosc-timeline_size_max_fullscreen=40";
    };
    scripts = with pkgs.mpvScripts; [
      uosc
    ];
  };
}
