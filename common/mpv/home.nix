{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.mpv;
in
{
  imports = [
    ./anime4k.nix
    ./manga-reader.nix
    ./uosc.nix
  ];

  options.my.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # vid.stab only available on ffmpeg-full, but the closure is much bigger
      ffmpeg
      yt-dlp
    ];

    programs.mpv = {
      enable = true;
      bindings = {
        # https://github.com/mpv-player/mpv/blob/master/etc/input.conf
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
        slang = "chi";
        sub-auto = "fuzzy";
        sub-codepage = "gbk";
        # Useful for DobbyVision 10bit video
        vo = "gpu-next";
      };
      scriptOpts.osc = lib.mkDefault {
        seekbarstyle = "knob";
        deadzonesize = 1;
        osc-minmousemove = 1;
      };
    };
  };
}
