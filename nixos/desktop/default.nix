{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.desktop;

in
{
  options.my.desktop = {
    enable = mkEnableOption (mdDoc "desktop");
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

    nix.daemonCPUSchedPolicy = "idle";

    programs.gnupg.agent.enable = true;

    hm = {
      my.firefox.enable = true;
      my.mpv.enable = true;
    };

  };
}
