{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.swayidle;

in {
  options.my.swayidle = {
    enable = mkEnableOption (mdDoc "swayidle");
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swayidle
    ];

    xdg.configFile."swayidle/config".text = ''
      timeout 1800 'swaylock -f'
      timeout 2400 'swaymsg "output * power off"' resume 'swaymsg "output * power on"'
      before-sleep 'swaylock -f'
    '';

    wayland.windowManager.sway = {
      config = {
        keybindings = let mod = config.wayland.windowManager.sway.config.modifier; in lib.mkOptionDefault {
          "--release ${mod}+Escape" = "exec pkill -x -USR1 swayidle";
        };
        startup = [{ command = "swayidle -w"; }];
      };
    };

  };
}
