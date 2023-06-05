{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkMerge;
  cfg = config.my.sway;

in {
  options.my.sway = {
    enable = mkEnableOption (mdDoc "sway");
    autologin = mkEnableOption (mdDoc "autologin") // { default = true; };
    xdgAutostart = mkEnableOption (mdDoc "xdgAutostart");
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      programs.sway = {
        enable = true;
        package = null;
      };
    })

    (mkIf cfg.autologin {
      # to start initial_session again, run `/run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "sway";
        user = config.my.user;
      };
    })

    (mkIf cfg.xdgAutostart {
      services.xserver.desktopManager.runXdgAutostartIfNone = true;
    })

  ]);
}
