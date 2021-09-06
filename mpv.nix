{ config, lib, pkgs, ... }:

let
  anime4k = pkgs.anime4k;
  low1k = {
    "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
    "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Modern 1080p (Fast)"'';
    "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Light_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Modern 720p->1080p (Fast)"'';
    "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Modern SD->1080p (Fast)"'';
    "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Light_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_Moderate_M.glsl"; show-text "Anime4K: Old SD->1080p (Fast)"'';
  };

in

{
  programs.mpv = {
    enable = true;
    bindings = {
      Y = "add sub-scale +0.1";                # increase subtitle font size
      G = "add sub-scale -0.1";                # decrease subtitle font size
      y = "sub_step -1";                       # immediately display next subtitle
      g = "sub_step +1";                       # previous
      R = "cycle_values window-scale 2 0.5 1"; # switch between 2x, 1/2, unresized window size
    } // low1k;
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
