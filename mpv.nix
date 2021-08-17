{ config, lib, pkgs, ... }:

{
  # environment.systemPackages = [ pkgs.mpv ];
  home-manager.users."${config.my.user}".programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      force-window = true;
    };
  };
}
