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
    mkOption
    types
    ;
  cfg = config.my.wayland;
  sessionName = builtins.elemAt (builtins.split " " cfg.session) 0;
in
{
  options.my.wayland = {
    enable = mkEnableOption "wayland";
    autologin = mkEnableOption "autologin" // {
      default = true;
    };
    session = mkOption { type = types.str; };
    xdgAutostart = mkEnableOption "xdgAutostart";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hm.my.wayland.enable = true;

      # https://github.com/swaywm/sway/wiki/Running-programs-natively-under-Wayland
      environment.sessionVariables = {
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      environment.systemPackages = with pkgs; [
        (runCommand "fuzzel" { buildInputs = [ makeWrapper ]; } ''
          options="--lines=8 --no-icons --font=monospace:pixelsize=20 --background-color=2E3440FF --text-color=D8DEE9FF --selection-color=4C566AFF --selection-text-color=E8DEE9FF --terminal=footclient --log-level=error"
          makeWrapper ${fuzzel}/bin/fuzzel $out/bin/fuzzel --add-flags "$options"
          # for passmenu
          makeWrapper ${fuzzel}/bin/fuzzel $out/bin/dmenu-wl --add-flags "--dmenu $options"
        '')
        foot
        pulsemixer
        qt5.qtwayland
        qt6.qtwayland
        swaybg
        wev
        wtype
        xdg-utils
      ];

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.greetd}/bin/agreety --cmd 'systemd-cat --identifier=${sessionName} ${cfg.session}'";
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

      # to start initial_session again, run `rm /run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "systemd-cat --identifier=${sessionName} ${cfg.session}";
        user = config.my.user;
      };
    })

    (mkIf cfg.xdgAutostart { services.xserver.desktopManager.runXdgAutostartIfNone = true; })
  ]);
}
