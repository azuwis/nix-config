{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault mkEnableOption mkIf;
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
    my.niri.enable = true;
    programs.sway.enable = true;
    my.theme.enable = true;
    programs.wayland.session = mkDefault "niri-session-custom";
    # programs.wayland.session = "sway";

    environment.systemPackages = with pkgs; [
      chromium
      evemu
      evtest
    ];

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
    };

    programs.firefox.enable = true;

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.settings = {
      default-cache-ttl = 14400;
      max-cache-ttl = 14400;
    };
    # Keyboard typing on pinentry-gnome3 stucks
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;

    programs.mpv.enable = true;
  };
}
