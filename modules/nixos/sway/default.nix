{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.sway;

in {
  options.my.sway = {
    enable = mkEnableOption (mdDoc "sway");
  };

  config = mkIf cfg.enable {
    programs.sway = {
      enable = true;
      package = null;
    };
    # services.xserver.desktopManager.runXdgAutostartIfNone = true;
  };
}
