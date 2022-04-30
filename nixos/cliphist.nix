{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
    xdg-utils
  ];

  wayland.windowManager.sway = {
    config = {
      keybindings = let mod = config.wayland.windowManager.sway.config.modifier; in lib.mkOptionDefault {
        "${mod}+p" = "exec cliphist list | dmenu-wl | cliphist decode | wl-copy";
      };
      startup = [{ command = "wl-paste --watch cliphist store"; }];
    };
  };
}
