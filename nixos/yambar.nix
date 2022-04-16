{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.yambar ];

  wayland.windowManager.sway = {
    config = {
      bars = [];
      startup = [{
        command = "yambar";
      }];
    };
  };
}
