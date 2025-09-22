{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sunshine;

  swayConfig = pkgs.replaceVarsWith {
    name = "sunshine-sway.conf";
    src = ../sway/config;
    replacements = {
      inherit (config.programs.wayland) terminal;
      wallpaper = pkgs.wallpapers.default;
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
      extraConfig = ''
        default_border normal
        default_floating_border normal
        bindsym BTN_RIGHT kill

        seat seat0 fallback false
        # All mouse like devices are pass through Mouse_passthrough,
        # add the virtual devices will double the evnets and thus the move speed.
        # seat seat0 attach "1356:3302:Sunshine_DualSense_(virtual)_pad_Touchpad"
        seat seat0 attach "48879:57005:Keyboard_passthrough"
        seat seat0 attach "48879:57005:Mouse_passthrough"
        seat seat0 attach "48879:57005:Mouse_passthrough_(absolute)"
        seat seat0 attach "48879:57005:Pen_passthrough"
        seat seat0 attach "48879:57005:Touch_passthrough"

        # input "48879:57005:Mouse_passthrough" accel_profile flat
        input "48879:57005:Mouse_passthrough" pointer_accel -1
        output HEADLESS-1 mode ${cfg.mode}

        assign [app_id="^sunshine-terminal$"] 9
        exec foot --app-id=sunshine-terminal

        exec ${lib.getExe pkgs.sunshine} "$SUNSHINE_CONFIG"
      ''
      + lib.concatMapStrings (entry: "exec ${lib.concatStringsSep " " entry}\n") (
        builtins.attrValues (
          lib.filterAttrs (
            name: value:
            builtins.elem name [
              "fcitx5"
              "foot"
              "yambar"
            ]
          ) config.programs.wayland.startup
        )
      );
    };
  };
in
{
  options.services.sunshine = {
    mode = lib.mkOption {
      type = lib.types.str;
      default = "1920x1080@60Hz";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = config.my.user;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "uhid" ];

    hardware.uinput.enable = true;
    users.users.${cfg.user}.extraGroups = [ "uinput" ];

    # udevadm info -a [/sys/device/...|/dev/...]
    # udevadm monitor --environment --property --udev
    # https://github.com/LizardByte/Sunshine/blob/master/src_assets/linux/misc/60-sunshine.rules
    # KERNEL=="hidraw*", ATTRS{name}=="Sunshine PS5 (virtual) pad", OWNER="${cfg.user}"
    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="uhid", GROUP="uinput", MODE="0660"
      SUBSYSTEMS=="input", ATTRS{name}=="Sunshine * (virtual) pad*", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="beef", ATTRS{id/product}=="dead", ATTRS{name}=="* passthrough*", OWNER="${cfg.user}"
    '';

    programs.sway.enable = true;
    # swaymsg -s /run/user/*/sway-ipc.*.sock --pretty --type get_inputs | awk '/Identifier:/ {print $2}'
    programs.sway.extraConfig = ''
      input "1356:3302:Sunshine_DualSense_(virtual)_pad_Touchpad" events disabled
      input "48879:57005:Keyboard_passthrough" events disabled
      input "48879:57005:Mouse_passthrough" events disabled
      input "48879:57005:Mouse_passthrough_(absolute)" events disabled
      input "48879:57005:Pen_passthrough" events disabled
      input "48879:57005:Touch_passthrough" events disabled
    '';

    # Make avahi optional
    services.avahi.enable = lib.mkOverride 999 false;

    systemd.user.services.sunshine.serviceConfig.Environment = [
      "PATH=%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
    ];

    services.sunshine = {
      autoStart = true;
      openFirewall = true;

      package = pkgs.writeShellScriptBin "sunshine-sway" ''
        export LIBSEAT_BACKEND=builtin
        export SEATD_VTBOUND=0
        export WLR_BACKENDS=headless,libinput
        export WLR_LIBINPUT_NO_DEVICES=1
        unset DBUS_SESSION_BUS_ADDRESS

        export SUNSHINE_CONFIG="$1"
        exec sway --config ${swayConfig}
      '';

      settings = {
        channels = 2;
        fps = "[30, 60]";
        origin_web_ui_allowed = "pc";
        resolutions = "[1280x720, 1920x1080]";
      };

      applications = {
        # moonlight see no apps if env not set
        env = { };
        apps =
          let
            mkImage =
              { url, hash }:
              let
                image = pkgs.fetchurl { inherit url hash; };
              in
              pkgs.runCommand "${lib.nameFromURL url "."}.png" { } ''
                ${pkgs.imagemagick}/bin/magick ${image} -background none -gravity center -extent 600x800 $out
              '';
            cemu-prep-cmd = [
              {
                do = "${./scripts}/cemu-do.sh";
                undo = "${./scripts}/cemu-undo.sh";
              }
            ];
            yuzu-prep-cmd = [
              {
                do = pkgs.writeShellScript "yuzu-do" ''
                  sed -e '2,$s|^|player_0_|' "$HOME/.config/yuzu/input/Sunshine.ini" | ${pkgs.crudini}/bin/crudini --merge "$HOME/.config/yuzu/qt-config.ini"
                '';
                undo = pkgs.writeShellScript "yuzu-undo" ''
                  sed -e '2,$s|^|player_0_|' "$HOME/.config/yuzu/input/Local.ini" | ${pkgs.crudini}/bin/crudini --merge "$HOME/.config/yuzu/qt-config.ini"
                '';
              }
            ];
          in
          [
            {
              name = "Z Desktop";
              image-path = pkgs.runCommand "desktop.png" { } ''
                ${pkgs.imagemagick}/bin/magick -density 1200 -background none ${pkgs.adwaita-icon-theme}/share/icons/Adwaita/scalable/devices/input-keyboard.svg -resize 500x -gravity center -extent 600x800 $out
              '';
            }
            {
              name = "BotW";
              image-path = mkImage {
                url = "https://assets-prd.ignimgs.com/2022/06/14/zelda-breath-of-the-wild-1655249167687.jpg?width=600";
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
                ${pkgs.imagemagick}/bin/magick -density 1200 -background none ${pkgs.torzu}/share/icons/hicolor/scalable/apps/onion.torzu_emu.torzu.svg -resize x500 -gravity center -extent 600x800 $out
              '';
              cmd = "yuzu";
              prep-cmd = yuzu-prep-cmd;
            }
          ];
      };
    };
  };
}
