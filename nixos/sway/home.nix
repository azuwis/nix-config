{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.my.sway;
in
{
  options.my.sway = {
    enable = mkEnableOption "sway";
    startupLocked = mkEnableOption "startupLocked";
    xdgAutostart = mkEnableOption "xdgAutostart";

    tmenu = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      my.cliphist.enable = true;
      # Hi-Res scroll is better
      my.firefox.env.GDK_BACKEND = mkDefault "x11";
      my.foot.enable = true;
      my.swayidle.enable = mkDefault true;
      # my.waybar.enable = mkDefault true;
      my.yambar.enable = mkDefault true;

      home.packages = with pkgs; [
        (runCommand "fuzzel" { buildInputs = [ makeWrapper ]; } ''
          options="--lines=8 --no-icons --font=monospace:pixelsize=20 --background-color=2E3440FF --text-color=D8DEE9FF --selection-color=4C566AFF --selection-text-color=E8DEE9FF --terminal=footclient --log-level=error"
          makeWrapper ${fuzzel}/bin/fuzzel $out/bin/fuzzel --add-flags "$options"
          # for passmenu
          makeWrapper ${fuzzel}/bin/fuzzel $out/bin/dmenu-wl --add-flags "--dmenu $options"
        '')
        swappy
        sway-contrib.grimshot
        wev
        wtype
      ];

      wayland.windowManager.sway = {
        enable = true;
        package = null;
        config = {
          # Apps
          # swaymsg -t get_tree | less
          assigns = {
            "2" = [
              { app_id = "^firefox$"; }
              { class = "^firefox$"; }
            ];
          };
          floating.criteria = [ { app_id = "^tmenu|mpv$"; } ];
          window.commands = [
            {
              command = "inhibit_idle fullscreen";
              criteria = {
                app_id = ''^info\.cemu\.Cemu$'';
              };
            }
            {
              command = "inhibit_idle fullscreen";
              criteria = {
                class = ''^yuzu$'';
              };
            }
          ];
          # Border
          floating.titlebar = false;
          gaps.smartBorders = "no_gaps";
          window = {
            border = 1;
            hideEdgeBorders = "both";
            titlebar = false;
          };
          # Colors
          colors = {
            focused = {
              background = "#285577";
              border = "#4c7899";
              childBorder = "#002b36";
              indicator = "#2e9ef4";
              text = "#ffffff";
            };
          };
          # Keybindings
          menu = "fuzzel";
          keybindings =
            let
              mod = config.wayland.windowManager.sway.config.modifier;
            in
            lib.mkOptionDefault {
              "${mod}+Tab" = "workspace back_and_forth";
              # stop graphical-session.target so services like foot will not try to restart itself
              "${mod}+Shift+e" = mkIf config.wayland.windowManager.sway.systemd.enable "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'systemctl --user stop graphical-session.target; swaymsg exit'";
              "${mod}+Shift+p" = "exec ${cfg.tmenu} passfzf";
              "${mod}+c" = "floating toggle; resize set 75 ppt 75 ppt; move absolute position center";
              "--release --no-repeat ${mod}+Escape" = mkDefault "exec swaylock";
              "Print" = "grimshot save - | swappy -f -";
              "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };
          # Inputs/outputs
          input = {
            "type:keyboard" = {
              repeat_delay = "300";
              repeat_rate = "33";
            };
            "type:touchpad" = {
              drag_lock = "enabled";
              dwt = "enabled";
              tap = "enabled";
              scroll_factor = "0.6";
            };
            # "<touchpad>" = {
            #   accel_profile = "adaptive";
            #   natural_scroll = "enabled";
            #   pointer_accel = "0.28";
            #   scroll_method = "edge";
            # };
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
      wayland.windowManager.sway.config.startup = [ { command = "swaylock"; } ];
    })

    (mkIf cfg.xdgAutostart {
      wayland.windowManager.sway.config.startup = [
        { command = "systemctl --user start xdg-autostart-if-no-desktop-manager.target"; }
      ];
    })
  ]);
}
