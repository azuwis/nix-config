{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkDefault mkEnableOption mkIf mkMerge;
  cfg = config.my.sway;

in {
  options.my.sway = {
    enable = mkEnableOption (mdDoc "sway");
    autologin = mkEnableOption (mdDoc "autologin") // { default = true; };
    xdgAutostart = mkEnableOption (mdDoc "xdgAutostart");
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      hm.my.sway.enable = true;

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.greetd}/bin/agreety --cmd sway";
          };
        };
      };

      programs.sway = {
        enable = true;
        package = null;
      };
    })

    (mkIf cfg.autologin {
      hm.my.sway.startupLocked = mkDefault true;

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
