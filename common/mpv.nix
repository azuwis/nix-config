{ config, lib, pkgs, ... }:

let
  anime4k = pkgs.anime4k;
  # curl -sL https://github.com/bloc97/Anime4K/raw/master/GLSL_Instructions.md | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e 's|;\$|:$|g' -e "s| |\" = ''|" -e 's|^|    "|' -e "s|$|'';|"
  low1k = {
    "CTRL+1" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"'';
    "CTRL+2" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"'';
    "CTRL+3" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"'';
    "CTRL+4" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"'';
    "CTRL+5" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"'';
    "CTRL+6" = ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_S.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"'';
    "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
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
      slang = "chi";
      sub-auto = "fuzzy";
      sub-codepage = "gbk";
    };
  };
  xdg.configFile."mpv/fonts.conf".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "../fonts.dtd">
    <fontconfig>
      <dir>/System/Library/Fonts</dir>
      <!-- <dir>/Library/Fonts</dir> -->
      <!-- <dir>~/Library/Fonts</dir> -->

      <!-- Default fonts for sans, serif, monospace -->
      <alias>
        <family>sans-serif</family>
          <prefer>
            <family>PingFang SC</family>
          </prefer>
      </alias>
      <alias>
        <family>serif</family>
          <prefer>
            <family>Songti SC</family>
          </prefer>
      </alias>
      <alias>
        <family>monospace</family>
          <prefer>
            <family>Menlo</family>
            <family>PingFang SC</family>
          </prefer>
      </alias>
    </fontconfig>
  '';
}
