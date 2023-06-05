{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkMerge;
  cfg = config.my.sway;

in {
  options.my.sway = {
    enable = mkEnableOption (mdDoc "sway");
    xdgAutostart = mkEnableOption (mdDoc "xdgAutostart");
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      programs.sway = {
        enable = true;
        package = null;
      };
    })

    (mkIf cfg.xdgAutostart {
      services.xserver.desktopManager.runXdgAutostartIfNone = true;
    })

  ]);
}
