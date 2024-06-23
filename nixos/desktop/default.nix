{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.desktop;
in
{
  options.my.desktop = {
    enable = mkEnableOption "desktop";
  };

  config = mkIf cfg.enable {
    my.android.enable = true;
    my.bluetooth.enable = true;
    my.fcitx5.enable = true;
    my.sway.enable = true;
    my.theme.enable = true;

    environment.systemPackages = with pkgs; [
      evemu
      evtest
      chromium
      subfinder
    ];

    # Enable chromium native wayland
    # environment.sessionVariables.NIXOS_OZONE_WL = "1";

    nix.daemonCPUSchedPolicy = "idle";

    programs.gnupg.agent.enable = true;
    # Keyboard typing on pinentry-gnome3 stucks
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    hm = {
      my.firefox.enable = true;
      my.mpv.enable = true;
    };
  };
}
