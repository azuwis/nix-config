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
  inherit (config.my) scale;
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
    terminal = mkOption { type = types.str; };
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
        (writeShellScriptBin "initlock" ''
          if [ -e /run/greetd.run ]; then
            now=$(date +%s)
            startup=$(stat -c %Y /run/greetd.run)
            if [ "$((now - startup))" -gt 10 ]; then
              exit
            fi
          fi
          swaylock --daemonize --image "${pkgs.wallpapers.default}"
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

      programs.foot.enable = true;

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "monospace:pixelsize=20";
            icons-enabled = false;
            lines = 8;
            terminal = cfg.terminal;
          };
          colors = {
            background = "2e3440ff";
            text = "d8dee9ff";
            selection = "4c566aff";
            selection-text = "e8dee9ff";
          };
        };
      };

      programs.swaylock = {
        enable = true;
        settings = {
          color = "2E3440";
          font-size = 24 * scale;
          ignore-empty-password = true;
          indicator-idle-visible = true;
          indicator-radius = 100;
          show-failed-attempts = true;
        };
      };

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
      my.niri.initlock = mkDefault true;
      hm.my.sway.initlock = mkDefault true;

      # to start initial_session again, run `rm /run/greetd.run; systemctl restart greetd`
      services.greetd.settings.initial_session = {
        command = "systemd-cat --identifier=${sessionName} ${cfg.session}";
        user = config.my.user;
      };
    })

    (mkIf cfg.initlock {
      my.niri.initlock = true;
      hm.my.sway.initlock = true;
    })

    (mkIf cfg.xdgAutostart { services.xserver.desktopManager.runXdgAutostartIfNone = true; })
  ]);
}
