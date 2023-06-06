{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.desktop;

in {
  options.my.desktop = {
    enable = mkEnableOption (mdDoc "desktop");
  };

  config = mkIf cfg.enable {
    my.sway.enable = true;
    
    hm.my.desktop.enable = true;

    nix.daemonCPUSchedPolicy = "idle";

  };
}
