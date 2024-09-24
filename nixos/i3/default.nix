{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    ;
  cfg = config.my.i3;
in
{
  options.my.i3 = {
    enable = mkEnableOption "i3";
    autologin = mkEnableOption "autologin" // {
      default = true;
    };
    xdgAutostart = mkEnableOption "xdgAutostart";
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      hm.my.i3.enable = true;

      programs.dconf.enable = true;

      services.xserver = {
        enable = true;
        autoRepeatDelay = 300;
        autoRepeatInterval = 33;
        extraDisplaySettings = "Virtual 1920 1080";
        displayManager.startx.enable = true;
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.greetd}/bin/agreety --cmd 'systemd-cat --identifier=startx startx'";
          };
        };
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
    })

    (mkIf cfg.autologin {
      hm.my.i3.initlock = mkDefault true;

      # to start initial_session again, run `/run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "systemd-cat --identifier=startx startx";
        user = config.my.user;
      };
    })

    (mkIf cfg.xdgAutostart { services.xserver.desktopManager.runXdgAutostartIfNone = true; })
  ]);
}
