{ config, lib, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      force-window = true;
    };
  };
}
