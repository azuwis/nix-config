{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.desktop;
in
{
  options.desktop = {
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
    programs.chromium.enhance = true;
    programs.fcitx5.enable = true;
    programs.firefox.enhance = true;
    programs.gnupg.agent = {
      enable = true;
      # Keyboard typing on pinentry-gnome3 stucks
      pinentryPackage = pkgs.pinentry-qt;
      settings = {
        default-cache-ttl = 14400;
        max-cache-ttl = 14400;
      };
    };
    programs.mpv.enhance = true;
    programs.niri.enable = true;
    # programs.sway.enhance = true;
    programs.wayland.session = mkDefault "niri-session";
    # programs.wayland.session = "sway";

    # Reduce 700M closure size
    services.speechd.enable = false;

    theme.enable = true;
  };
}
