{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.swayidle;
in
{
  options.my.swayidle = {
    enable = mkEnableOption "swayidle";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ swayidle ];

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -f";
        }
      ];
      timeouts = [
        {
          timeout = 1800;
          command = "${pkgs.swaylock}/bin/swaylock -f";
        }
        {
          timeout = 2400;
          command = ''${pkgs.sway}/bin/swaymsg "output * power off"'';
          resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * power on"'';
        }
      ];
    };

    wayland.windowManager.sway.config.keybindings =
      let
        mod = config.wayland.windowManager.sway.config.modifier;
      in
      lib.mkOptionDefault { "--release --no-repeat ${mod}+Escape" = "exec pkill -x -USR1 swayidle"; };

    # wayland.windowManager.sway.config.startup = [{ command = "swayidle -w"; }];
  };
}
