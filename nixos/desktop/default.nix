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
    my.firefox.enable = true;
    my.sway.enable = true;
    my.theme.enable = true;

    hm.my.desktop.enable = true;

    nix.daemonCPUSchedPolicy = "idle";
  };
}
