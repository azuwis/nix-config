{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkDefault mkIf mkMerge;
  cfg = config.my.sway;

in
{
  options.my.sway = {
    enable = mkEnableOption (mdDoc "sway");
    startupLocked = mkEnableOption (mdDoc "startupLocked");
    xdgAutostart = mkEnableOption (mdDoc "xdgAutostart");
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      my.cliphist.enable = true;
      my.foot.enable = true;
      my.swayidle.enable = mkDefault true;
      my.yambar.enable = true;

      home.packages = with pkgs; [
        (runCommand "fuzzel" { buildInputs = [ makeWrapper ]; } ''
          options="--lines=8 --no-icons --font=monospace:pixelsize=20 --background-color=2E3440FF --text-color=D8DEE9FF --selection-color=4C566AFF --selection-text-color=E8DEE9FF --terminal=footclient --log-level=error"
          makeWrapper ${fuzzel}/bin/fuzzel $out/bin/fuzzel --add-flags "$options"
          # for passmenu
          makeWrapper ${fuzzel}/bin/fuzzel $out/bin/dmenu-wl --add-flags "--dmenu $options"
        '')
        pulsemixer
        qt5.qtwayland
        swappy
        sway-contrib.grimshot
        wev
      ];

      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        systemdIntegration = false;
        extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          export QT_QPA_PLATFORM=wayland-egl
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
        config = {
          # Apps
          # swaymsg -t get_tree | less
          assigns = {
            "2" = [{ app_id = "^firefox$"; }];
          };
          floating.criteria = [
            { app_id = "^mpv$"; }
          ];
          window.commands = [
            {
              command = "inhibit_idle fullscreen";
              criteria = { app_id = ''^info\.cemu\.Cemu$''; };
            }
          ];
          # Border
          gaps.smartBorders = "no_gaps";
          window.hideEdgeBorders = "both";
          # Keybindings
          menu = "fuzzel";
          keybindings = let mod = config.wayland.windowManager.sway.config.modifier; in lib.mkOptionDefault {
            "${mod}+Tab" = "workspace back_and_forth";
            # stop graphical-session.target so services like foot will not try to restart itself
            "${mod}+Shift+e" = mkIf config.wayland.windowManager.sway.systemdIntegration "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'systemctl --user stop graphical-session.target; swaymsg exit'";
            "${mod}+Shift+p" = "exec passmenu";
            "${mod}+c" = "floating enable; move absolute position center";
            "--release --no-repeat ${mod}+Escape" = mkDefault "exec swaylock";
            "Print" = "grimshot save - | swappy -f -";
            "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+";
            "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          # Inputs/outputs
          input = {
            "*" = {
              natural_scroll = "enabled";
            };
            "type:keyboard" = {
              repeat_delay = "300";
              repeat_rate = "33";
            };
            "type:touchpad" = {
              accel_profile = "adaptive";
              drag_lock = "enabled";
              dwt = "enabled";
              pointer_accel = "0.28";
              tap = "enabled";
              scroll_method = "edge";
              scroll_factor = "0.6";
            };
          };
          output."*".bg = "#2E3440 solid_color";
        };
        swaynag = {
          enable = true;
          settings."<config>".edge = "bottom";
        };
      };

      programs.swaylock = {
        enable = true;
        settings = {
          color = "2E3440";
          font-size = 24;
          ignore-empty-password = true;
          indicator-idle-visible = true;
          indicator-radius = 100;
          show-failed-attempts = true;
        };
      };

    })

    (mkIf cfg.startupLocked {
      wayland.windowManager.sway.config.startup = [{
        command = "swaylock";
      }];
    })

    (mkIf cfg.xdgAutostart {
      wayland.windowManager.sway.config.startup = [{
        command = "systemctl --user start xdg-autostart-if-no-desktop-manager.target";
      }];
    })

  ]);
}
