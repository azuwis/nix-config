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
    mkOption
    ;
  cfg = config.programs.swayidle;

  lockCommand = "blurlock";
  timeoutCommand = toString (
    pkgs.writeShellScript "swayidle-timeout-command" ''
      case "$XDG_CURRENT_DESKTOP" in
      niri) niri msg action power-off-monitors ;;
      sway) swaymsg "output * power off" ;;
      esac
    ''
  );
  resumeCommand = toString (
    pkgs.writeShellScript "swayidle-resume-command" ''
      case "$XDG_CURRENT_DESKTOP" in
      sway) swaymsg "output * power on" ;;
      esac
    ''
  );
in
{
  options.programs.swayidle = {
    enable = mkEnableOption "swayidle";

    finalPackage = mkOption {
      default = pkgs.wrapper {
        package = pkgs.swayidle;
        flags = [
          "-w"
          "timeout"
          "1500"
          "blurlock"
          "timeout"
          "1800"
          timeoutCommand
          "resume"
          resumeCommand
          "before-sleep"
          lockCommand
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.finalPackage ];
    programs.wayland.startup.swayidle = [ "swayidle" ];
  };
}
