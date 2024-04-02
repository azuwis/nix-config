{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.cliphist;

in
{
  options.my.cliphist = {
    enable = mkEnableOption "cliphist";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cliphist
      wl-clipboard
      xdg-utils
    ];

    wayland.windowManager.sway = {
      config = {
        keybindings = let mod = config.wayland.windowManager.sway.config.modifier; in lib.mkOptionDefault {
          "${mod}+p" = "exec ${config.my.sway.tmenu} sh -c 'cliphist list | fzf --reverse --no-info | cliphist decode 2>/dev/null | wl-copy'";
        };
        startup = [{ command = "wl-paste --watch cliphist store"; }];
      };
    };

  };
}
