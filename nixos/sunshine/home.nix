{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption mkPackageOptionMD optionalAttrs types;
  cfg = config.my.sunshine;
  json = pkgs.formats.json { };

  swayConfig = pkgs.runCommand "sunshine-sway.conf" { } ''
    {
    grep -Ev '(^exec jslisten|^exec swaylock|^exec swayidle|events disabled|dbus-update-activation-environment)' ${config.xdg.configFile."sway/config".source}
    echo '
    output HEADLESS-1 mode ${cfg.mode}
    seat seat0 fallback false
    seat seat0 attach "48879:57005:Keyboard_passthrough"
    seat seat0 attach "48879:57005:Touchscreen_passthrough"
    seat seat0 attach "1133:16440:Logitech_Wireless_Mouse_PID:4038"
    default_border normal
    default_floating_border normal
    bindsym --release BTN_RIGHT kill
    exec sunshine
    '
    } > $out
  '';

in
{
  options.my.sunshine = {
    enable = mkEnableOption (mdDoc "sunshine");

    cudaSupport = mkEnableOption (mdDoc "cuda support, only useful in Nvidia+X11 setup");

    package = mkPackageOptionMD pkgs "sunshine" { } // (optionalAttrs cfg.cudaSupport {
      default = pkgs.sunshine.override {
        cudaSupport = true;
        stdenv = pkgs.cudaPackages.backendStdenv;
      };
    });

    conf = mkOption {
      type = types.str;
      default = ''
        # capture = nvfbc
        # capture = wlr
        channels = 2
        fps = [30,60]
        origin_web_ui_allowed = pc
        resolutions = [
            1280x720,
            1920x1080
        ]
      '';
    };

    mode = mkOption {
      type = types.str;
      default = "1920x1080@60Hz";
    };

    apps = mkOption {
      type = json.type;
      default = {
        # moonlight see no apps if env not set
        env = { };
        apps =
          let
            cemu-prep-cmd = [{
              do = "${./scripts}/cemu-do.sh";
              undo = "${./scripts}/cemu-undo.sh";
            }];
            yuzu-prep-cmd = [{
              do = pkgs.writeShellScript "yuzu-do" ''
                sed -e '2,$s|^|player_0_|' "$HOME/.config/yuzu/input/Sunshine.ini" | ${pkgs.crudini}/bin/crudini --merge "$HOME/.config/yuzu/qt-config.ini"
              '';
              undo = pkgs.writeShellScript "yuzu-undo" ''
                sed -e '2,$s|^|player_0_|' "$HOME/.config/yuzu/input/Local.ini" | ${pkgs.crudini}/bin/crudini --merge "$HOME/.config/yuzu/qt-config.ini"
              '';
            }];
          in
          [
            {
              name = "Z Desktop";
              image-path = pkgs.runCommand "desktop.png" { } ''
                ${pkgs.imagemagick}/bin/convert -density 1200 -resize 500x -background none ${pkgs.gnome.adwaita-icon-theme}/share/icons/Adwaita/scalable/devices/input-keyboard.svg -gravity center -extent 600x800 $out
              '';
            }
            {
              name = "BotW";
              image-path =
                let
                  image = pkgs.fetchurl {
                    name = "botw.png";
                    url = "https://static.wikia.nocookie.net/logopedia/images/5/53/763px-BotW_NA_Logo.png/revision/latest/scale-to-width-down/600";
                    hash = "sha256-8xaJPg5mRSPyrpQay+m/6RpwHV7BT5HSQ1YhCrPkFZQ=";
                  };
                in
                pkgs.runCommand "botw.png" { } ''
                  ${pkgs.imagemagick}/bin/convert ${image} -background none -gravity center -extent 600x800 $out
                '';
              cmd = "cemu --fullscreen --title-id 00050000101c9300";
              prep-cmd = cemu-prep-cmd;
            }
            {
              name = "TotK";
              image-path =
                let
                  image = pkgs.fetchurl {
                    name = "totk.png";
                    url = "https://static.wikia.nocookie.net/zelda_gamepedia_en/images/4/4c/TotK_English_Logo.png/revision/latest/scale-to-width-down/600";
                    hash = "sha256-nX2UDvm2oSLvnY9gJJluGU3mwsFGwwKAqUZEexj8mCQ=";
                  };
                in
                pkgs.runCommand "totk.png" { } ''
                  ${pkgs.imagemagick}/bin/convert ${image} -background none -gravity center -extent 600x800 $out
                '';
              cmd = "yuzu -f -g $(HOME)/Games/Switch/TotK.nsp";
              prep-cmd = yuzu-prep-cmd;
            }
            {
              name = "Yuzu";
              image-path = pkgs.runCommand "yuzu.png" { } ''
                ${pkgs.imagemagick}/bin/convert -resize x420 -background none ${pkgs.yuzu-ea}/share/icons/hicolor/scalable/apps/org.yuzu_emu.yuzu.svg -gravity center -extent 600x800 $out
              '';
              cmd = "yuzu";
              prep-cmd = yuzu-prep-cmd;
            }
          ];
      };
    };

  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."sunshine/sunshine.conf".text = cfg.conf;
    xdg.configFile."sunshine/apps.json".source = json.generate "sunshine-apps.json" cfg.apps;

    systemd.user.services.sunshine = {
      Install.WantedBy = [ "default.target" ];
      Service = {
        Environment = [
          "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
          "LIBSEAT_BACKEND=builtin"
          "SEATD_VTBOUND=0"
          "WLR_BACKENDS=headless,libinput"
          "WLR_LIBINPUT_NO_DEVICES=1"
          "DBUS_SESSION_BUS_ADDRESS="
        ];
        ExecStart = "/run/current-system/sw/bin/sway -c ${swayConfig}";
        Restart = "on-failure";
        SyslogIdentifier = "sunshine";
      };
    };

    wayland.windowManager.sway.extraConfig = ''
      input "48879:57005:Keyboard_passthrough" events disabled
      input "48879:57005:Touchscreen_passthrough" events disabled
      input "1133:16440:Logitech_Wireless_Mouse_PID:4038" events disabled
    '';
  };
}
