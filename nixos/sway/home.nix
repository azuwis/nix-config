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
    {
      my.cliphist.enable = true;
      my.foot.enable = true;
      my.swayidle.enable = mkDefault true;
      # my.waybar.enable = mkDefault true;
      my.yambar.enable = mkDefault true;

      home.packages = with pkgs; [
        swappy
        sway-contrib.grimshot
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
          modifier = "Mod4";
          keybindings =
            let
              mod = config.wayland.windowManager.sway.config.modifier;
            in
            lib.mkOptionDefault {
              "${mod}+Tab" = "workspace back_and_forth";
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
    }

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
