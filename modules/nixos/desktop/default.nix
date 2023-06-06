{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.desktop;

in {
  options.my.desktop = {
    enable = mkEnableOption (mdDoc "desktop");
  };

  config = mkIf cfg.enable {
    my.fcitx5.enable = true;
    my.sway.enable = true;
    my.theme.enable = true;
    
    hm.my.desktop.enable = true;

    hardware.bluetooth.enable = true;
    nix.daemonCPUSchedPolicy = "idle";

  };
}
