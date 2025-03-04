{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkForce
    mkMerge
    ;
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
          lockCommand = "blurlock";
          timeoutCommand = builtins.toString (
            pkgs.writeShellScript "swayidle-timeout-command" ''
              case "$XDG_CURRENT_DESKTOP" in
              niri) niri msg action power-off-monitors ;;
              sway) swaymsg "output * power off" ;;
              esac
            ''
          );
          resumeCommand = builtins.toString (
            pkgs.writeShellScript "swayidle-resume-command" ''
              case "$XDG_CURRENT_DESKTOP" in
              sway) swaymsg "output * power on" ;;
              esac
            ''
          );
        in
        {
          enable = true;
          events = [
            {
              event = "before-sleep";
              command = lockCommand;
            }
          ];
          timeouts = [
            {
              timeout = 1500;
              command = lockCommand;
            }
            {
              timeout = 1800;
              command = timeoutCommand;
              resumeCommand = resumeCommand;
            }
          ];
        };

      systemd.user.services.swayidle = {
        # WAYLAND_DISPLAY not set without this
        Unit.After = [ "graphical-session.target" ];

        Service = {
          Environment = mkForce "PATH=%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
        };
      };

    }

    (mkIf config.my.sway.enable {
      # wayland.windowManager.sway.config.startup = [{ command = "swayidle -w"; }];
    })
  ]);
}
