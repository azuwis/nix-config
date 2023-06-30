{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption types;
  cfg = config.my.sunshine;

  swayConfig = pkgs.runCommand "sunshine-sway.conf" {} ''
    {
    grep -Ev '(^exec swaylock|^exec swayidle|events disabled)' ${config.xdg.configFile."sway/config".source}
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

in {
  options.my.sunshine = {
    enable = mkEnableOption (mdDoc "sunshine");

    conf = mkOption {
      type = types.str;
      default = ''
        capture = wlr
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

  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.sunshine ];

    xdg.configFile."sunshine/sunshine.conf".text = cfg.conf;

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
        ExecStart = "/etc/profiles/per-user/%u/bin/sway -c ${swayConfig}";
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
