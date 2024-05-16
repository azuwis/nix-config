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

    services.swayidle =
      let
        swaylock = "${lib.getExe pkgs.swaylock} -f";
        swaymsg = lib.getExe' pkgs.sway "swaymsg";
      in
      {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = swaylock;
          }
        ];
        timeouts = [
          {
            timeout = 1800;
            command = swaylock;
          }
          {
            timeout = 2400;
            command = ''${swaymsg} "output * power off"'';
            resumeCommand = ''${swaymsg} "output * power on"'';
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
