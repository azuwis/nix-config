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
    initlock = mkEnableOption "initlock" // {
      default = cfg.autologin;
    };
    session = mkOption { type = types.str; };
    xdgAutostart = mkEnableOption "xdgAutostart";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hm.my.wayland.enable = true;

      # https://github.com/swaywm/sway/wiki/Running-programs-natively-under-Wayland
      environment.sessionVariables = {
        # Enable chromium native wayland
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      environment.systemPackages = with pkgs; [
        (writeShellScriptBin "blurlock" ''
          image=''${XDG_RUNTIME_DIR:-$HOME/.cache}/blurlock.png
          grim - | magick - -scale 10% -scale 1000% "$image"
          swaylock --daemonize --image "$image"
          rm "$image"
        '')
        (writeShellScriptBin "startuplock" ''
          if [ -e /run/greetd.run ]; then
            now=$(date +%s)
            startup=$(stat -c %Y /run/greetd.run)
            if [ "$((now - startup))" -gt 10 ]; then
              exit
            fi
          fi
          blurlock
        '')
        (writeShellScriptBin "swaylockx" ''
          pkill -x -USR1 swayidle || blurlock
        '')
        foot
        pulsemixer
        qt5.qtwayland
        qt6.qtwayland
        swaybg
        wev
        wtype
        xdg-utils
        grim
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
      hm.my.niri.startupLocked = mkDefault true;
      hm.my.sway.startupLocked = mkDefault true;

      # to start initial_session again, run `rm /run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "systemd-cat --identifier=${sessionName} ${cfg.session}";
        user = config.my.user;
      };
    })

    (mkIf cfg.initlock {
      hm.my.niri.startupLocked = true;
      hm.my.sway.startupLocked = true;
    })

    (mkIf cfg.xdgAutostart { services.xserver.desktopManager.runXdgAutostartIfNone = true; })
  ]);
}
