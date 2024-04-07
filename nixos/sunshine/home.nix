{ inputs, config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption mkPackageOption optionalAttrs types;
  cfg = config.my.sunshine;
  json = pkgs.formats.json { };

  swayConfig = pkgs.runCommand "sunshine-sway.conf" { } ''
    {
    grep -Ev '(^exec jslisten|^exec swaylock|^exec swayidle|events disabled|dbus-update-activation-environment)' ${config.xdg.configFile."sway/config".source}
    echo '
    default_border normal
    default_floating_border normal
    bindsym BTN_RIGHT kill

    seat seat0 fallback false
    seat seat0 attach "48879:57005:Keyboard_passthrough"
    seat seat0 attach "48879:57005:Touchscreen_passthrough"
    seat seat0 attach "1133:16440:Logitech_Wireless_Mouse_PID:4038"

    # input "1133:16440:Logitech_Wireless_Mouse_PID:4038" accel_profile flat
    input "1133:16440:Logitech_Wireless_Mouse_PID:4038" pointer_accel -1
    output HEADLESS-1 mode ${cfg.mode}

    assign [app_id="^sunshine-terminal$"] 9
    exec foot --app-id=sunshine-terminal

    exec sunshine
    '
    } > $out
  '';

in
{
  options.my.sunshine = {
    enable = mkEnableOption "sunshine";

    cudaSupport = mkEnableOption "cuda support, only useful in Nvidia+X11 setup";

    package = mkPackageOption pkgs "sunshine" { } // (optionalAttrs cfg.cudaSupport {
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
            mkImage = { url, hash }:
              let
                image = pkgs.fetchurl {
                  inherit url hash;
                };
              in
              pkgs.runCommand "${lib.nameFromURL url "."}.png" { } ''
                ${pkgs.imagemagick}/bin/convert ${image} -background none -gravity center -extent 600x800 $out
              '';
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
              image-path = mkImage {
                url = "https://assets-prd.ignimgs.com/2022/06/14/zelda-breath-of-the-wild-1655249167687.jpg";
                hash = "sha256-9AhOUgNuztTpqBLuvdTwLcJHEaKHc7F7YM6wzbzRDPk=";
              };
              cmd = "cemu --fullscreen --title-id 00050000101c9300";
              prep-cmd = cemu-prep-cmd;
            }
            {
              name = "NieR";
              image-path = mkImage {
                url = "https://assets-prd.ignimgs.com/2021/12/08/nierautomata-1638924135289.jpg?width=600";
                hash = "sha256-l3Q5APq27o5wwnB1nikUJVt1P3q1dMxeLx1MadCdwRE=";
              };
              cmd = "yuzu -f -g $(HOME)/Games/Switch/NieR.nsp";
              prep-cmd = yuzu-prep-cmd;
            }
            {
              name = "REReve";
              image-path = mkImage {
                url = "https://assets-prd.ignimgs.com/2021/12/22/resident-evil-revelations-1-button-1640136891229.jpg?width=600";
                hash = "sha256-5QUB9lirZrUk5X4mI3V/hrDsUsOKkv02ppLNheqW7mo=";
              };
              cmd = "yuzu -f -g $(HOME)/Games/Switch/REReve.nsp";
              prep-cmd = yuzu-prep-cmd;
            }
            {
              name = "TotK";
              image-path = mkImage {
                url = "https://assets-prd.ignimgs.com/2022/09/14/zelda-tears-of-the-kingdom-button-2k-1663127818777.jpg?width=600";
                hash = "sha256-z25bcucS1YOT9WRGxNv0fzTbhVaoNItpSLvujqz7CeM=";
              };
              cmd = "yuzu -f -g $(HOME)/Games/Switch/TotK.nsp";
              prep-cmd = yuzu-prep-cmd;
            }
            {
              name = "XenoChron3";
              image-path = mkImage {
                url = "https://assets-prd.ignimgs.com/2022/04/17/xenochron3-1650154074567.jpg?width=600";
                hash = "sha256-nJHIKkUbuLWilEqx9iR4MWaWLT0cPK3ptSeVhMH/4AE=";
              };
              cmd = "yuzu -f -g $(HOME)/Games/Switch/XenoChron3.nsp";
              prep-cmd = yuzu-prep-cmd;
            }
            {
              name = "Yuzu";
              image-path = pkgs.runCommand "yuzu.png" { } ''
                ${pkgs.imagemagick}/bin/convert -resize x420 -background none ${inputs.yuzu.packages.${pkgs.system}.early-access}/share/icons/hicolor/scalable/apps/org.yuzu_emu.yuzu.svg -gravity center -extent 600x800 $out
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
          "PATH=%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
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
