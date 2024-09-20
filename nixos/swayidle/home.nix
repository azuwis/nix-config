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
          swaylock = "swaylock -f";
          timeoutCommand = builtins.toString (
            pkgs.writeShellScript "swayidle-timeout-command" ''
              swaymsg "output * power off"
            ''
          );
          resumeCommand = builtins.toString (
            pkgs.writeShellScript "swayidle-resume-command" ''
              swaymsg "output * power on"
            ''
          );
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
              command = timeoutCommand;
              resumeCommand = resumeCommand;
            }
          ];
        };

      systemd.user.services.swayidle = {
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
