{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkForce
    mkMerge
    mkPackageOption
    ;
  cfg = config.my.niri;

  # Modify from https://github.com/YaLTeR/niri/blob/main/resources/niri-session
  # The original `systemctl --user --wait start niri.service` cause problem with `my.sunshine.enable`:
  # ```
  # niri::backend::tty: using as the render node: "/dev/dri/renderD128"
  # niri::backend::tty: device added: 57857 "/dev/dri/card1"
  # niri::backend::tty: error adding device: Failed to open device: Operation not permitted (os error 1)
  # ```
  niri-session-custom = pkgs.writeShellScriptBin "niri-session-custom" ''
    systemctl --user reset-failed
    niri --session
    systemctl --user stop niri-session.target
    systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
  '';
in
{
  options.my.niri = {
    enable = mkEnableOption "niri";
    package = mkPackageOption pkgs "niri" { };
    custom-session = mkEnableOption "niri custom session" // {
      default = config.my.wayland.session == "niri-session-custom";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hm.my.niri.enable = true;

      environment.systemPackages = with pkgs; [
        xwayland-satellite
      ];

      programs.niri.enable = true;
      programs.xwayland.enable = mkForce true;
      xdg.portal.wlr.enable = mkForce true;
    }

    (mkIf cfg.custom-session {
      hm.my.niri.extraConfig = ''
        spawn-at-startup "systemctl" "--user" "start" "niri-session.target"
      '';

      environment.systemPackages = [ niri-session-custom ];

      systemd.user.targets.niri-session = {
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
    })
  ]);
}
