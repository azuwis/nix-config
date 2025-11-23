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
    environment.systemPackages = with pkgs; [
      evemu
      evtest
    ];

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
    };

    programs.android.enable = true;
    programs.bluetooth.enable = true;
    programs.chromium.enable = true;
    programs.fcitx5.enable = true;
    programs.firefox.enable = true;
    programs.gnupg.agent = {
      enable = true;
      # Keyboard typing on pinentry-gnome3 stucks
      pinentryPackage = pkgs.pinentry-qt;
      settings = {
        default-cache-ttl = 14400;
        max-cache-ttl = 14400;
      };
    };
    programs.mpv.enable = true;
    programs.niri.enable = true;
    programs.sway.enable = true;
    programs.wayland.session = mkDefault "niri-session";
    # programs.wayland.session = "sway";

    theme.enable = true;
  };
}
