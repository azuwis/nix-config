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
      [[ ":$XDG_CURRENT_DESKTOP:" == *":niri:"* ]] && niri msg action power-off-monitors
      [[ ":$XDG_CURRENT_DESKTOP:" == *":sway:"* ]] && swaymsg "output * power off"
    ''
  );
  resumeCommand = toString (
    pkgs.writeShellScript "swayidle-resume-command" ''
      [[ ":$XDG_CURRENT_DESKTOP:" == *":sway:"* ]] && swaymsg "output * power on"
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
