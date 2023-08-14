{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkDefault mkIf mkMerge;
  cfg = config.my.i3;

in
{
  options.my.i3 = {
    enable = mkEnableOption (mdDoc "i3");
    startupLocked = mkEnableOption (mdDoc "startupLocked");
    xdgAutostart = mkEnableOption (mdDoc "xdgAutostart");
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      my.yambar.enable = true;

      home.packages = with pkgs; [
        (runCommand "rofi-dmenu" { } ''
          mkdir -p $out/bin
          ln -s ${rofi}/bin/rofi $out/bin/dmenu
        '')
        hsetroot
        i3lock
        pulsemixer
        xdotool
      ];

      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local config = {}
          if wezterm.config_builder then
            config = wezterm.config_builder()
          end

          config.color_scheme = 'nord'
          config.font_size = 14.0
          config.hide_tab_bar_if_only_one_tab = true

          return config
        '';
      };

      programs.rofi = {
        enable = true;
        theme = "${pkgs.fetchurl {
          url = "https://github.com/undiabler/nord-rofi-theme/raw/eebddcbf36052e140a9af7c86f1fbd88e31d2365/nord.rasi";
          sha256 = "sha256-3P7Fpsev0Y7oBtK+x2R4V4aCkdQThybUSySufNFGtl4=";
        }}";
      };

      home.file.".xinitrc".text = ''
        i3
      '';

      xsession.windowManager.i3 = {
        enable = true;
        config = {
          # Apps
          terminal = "wezterm";
          assigns = {
            "1" = [{ class = "^Firefox$"; }];
          };
          floating.criteria = [
            { class = "^Mpv$"; }
          ];
          # Border
          gaps.smartBorders = "no_gaps";
          window.hideEdgeBorders = "both";
          # Keybindings
          menu = "rofi -show drun";
          keybindings = let mod = config.xsession.windowManager.i3.config.modifier; in lib.mkOptionDefault {
            "${mod}+Tab" = "workspace back_and_forth";
            "${mod}+Shift+p" = "exec passmenu";
            "${mod}+c" = "floating enable; move absolute position center";
            "--release ${mod}+Escape" = mkDefault "exec i3lock --nofork --ignore-empty-password --color=2e3440";
            # "Print" = "";
            "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+";
            "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          # Startup
          startup = [
            { command = "hsetroot -solid '#2e3440'"; }
          ];
        };
      };

    })

    (mkIf cfg.startupLocked {
      xsession.windowManager.i3.config.startup = [{
        command = "i3lock --nofork --ignore-empty-password --color=2e3440";
      }];
    })

    (mkIf cfg.xdgAutostart {
      xsession.windowManager.i3.config.startup = [{
        command = "systemctl --user start xdg-autostart-if-no-desktop-manager.target";
      }];
    })

  ]);
}
