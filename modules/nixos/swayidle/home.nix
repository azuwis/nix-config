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
      timeout 300 'swaylock -f'
      timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"'
      before-sleep 'swaylock -f'
    '';

    wayland.windowManager.sway = {
      config = {
        keybindings = let mod = config.wayland.windowManager.sway.config.modifier; in lib.mkOptionDefault {
          "${mod}+Shift+l" = "exec pkill -USR1 swayidle";
        };
        startup = [{ command = "exec swayidle -w"; }];
      };
    };

  };
}
