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
  cfg = config.my.sway;
in
{
  options.my.sway = {
    enable = mkEnableOption "sway";
    autologin = mkEnableOption "autologin" // {
      default = true;
    };
    xdgAutostart = mkEnableOption "xdgAutostart";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hm.my.sway.enable = true;

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          foot
          pulsemixer
          qt5.qtwayland
          qt6.qtwayland
        ];
        extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.greetd}/bin/agreety --cmd 'systemd-cat --identifier=sway sway'";
          };
        };
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        extraConfig.pipewire = {
          "99-disable-bell"."context.properties"."module.x11.bell" = false;
        };
      };
      security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
    }

    (mkIf cfg.autologin {
      hm.my.sway.startupLocked = mkDefault true;

      # to start initial_session again, run `/run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "systemd-cat --identifier=sway sway";
        user = config.my.user;
      };
    })

    (mkIf cfg.xdgAutostart { services.xserver.desktopManager.runXdgAutostartIfNone = true; })
  ]);
}
