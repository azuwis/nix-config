{ config, lib, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    bindings = {
      Y = "add sub-scale +0.1";                # increase subtitle font size
      G = "add sub-scale -0.1";                # decrease subtitle font size
      y = "sub_step -1";                       # immediately display next subtitle
      g = "sub_step +1";                       # previous
      R = "cycle_values window-scale 2 0.5 1"; # switch between 2x, 1/2, unresized window size
    };
    config = {
      audio-display = false;
      force-window = true;
      hidpi-window-scale = false;
      hwdec = "auto";
      keep-open = true;
      keep-open-pause = false;
      osd-on-seek = false;
      profile = "gpu-hq";
      script-opts = "osc-seekbarstyle=knob,osc-deadzonesize=1,osc-minmousemove=1";
      sub-auto = "fuzzy";
      sub-codepage = "gbk";
    };
  };
}
