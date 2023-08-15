{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption mkPackageOptionMD types;
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

    package = mkPackageOptionMD pkgs "sunshine" { };

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
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
          {
            name = "BotW";
            image-path = "desktop-alt.png";
            cmd = "cemu --fullscreen --title-id 00050000101c9300";
            prep-cmd = [{
              do = "${./scripts}/cemu-do.sh";
              undo = "${./scripts}/cemu-undo.sh";
            }];
          }
          {
            name = "TotK";
            image-path = "desktop-alt.png";
            cmd = pkgs.writeShellScript "totk" ''
              QT_QPA_PLATFORM=xcb yuzu --fullscreen --game "$HOME/Games/Switch/TotK.nsp";
            '';
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
