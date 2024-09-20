{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.swayidle;
in
{
  options.my.swayidle = {
    enable = mkEnableOption "swayidle";
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
              timeout = 1500;
              command = swaylock;
            }
            {
              timeout = 1800;
              command = ''${swaymsg} "output * power off"'';
              resumeCommand = ''${swaymsg} "output * power on"'';
            }
          ];
        };

    }

    (mkIf config.my.sway.enable {
      # wayland.windowManager.sway.config.startup = [{ command = "swayidle -w"; }];
    })
  ]);
}
