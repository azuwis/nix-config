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
      # swaymsg -s /run/user/*/sway-ipc.*.sock --pretty --type get_inputs | awk '/Identifier:/ {print $2}'
      extraConfig = ''
        default_border normal
        default_floating_border normal
        bindsym BTN_RIGHT kill

        seat seat0 fallback false
        # All mouse like devices are pass through Mouse_passthrough,
        # add the virtual devices will double the evnets and thus the move speed.
        # seat seat0 attach "1356:3302:Sunshine_PS5_(virtual)_pad_Touchpad"
        seat seat0 attach "48879:57005:Keyboard_passthrough"
        seat seat0 attach "48879:57005:Mouse_passthrough"
        seat seat0 attach "48879:57005:Mouse_passthrough_(absolute)"
        seat seat0 attach "48879:57005:Pen_passthrough"
        seat seat0 attach "48879:57005:Touch_passthrough"

        # input "48879:57005:Mouse_passthrough" accel_profile flat
        input "48879:57005:Mouse_passthrough" pointer_accel -1
        bindsym $mod+m input "48879:57005:Mouse_passthrough" pointer_accel 0
        bindsym $mod+Shift+m input "48879:57005:Mouse_passthrough" pointer_accel -1

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
              "waybar"
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

    # Disable sunshine virtual events for real display
    # https://wayland.freedesktop.org/libinput/doc/latest/device-quirks.html
    # List of events https://gitlab.freedesktop.org/libinput/libinput/-/blob/main/src/evdev-frame.h?ref_type=heads#L48
    environment.etc."libinput/local-overrides.quirks".text = ''
      [Sunshine Virtual Mouse Keyboard]
      MatchVendor=0xBEEF
      MatchProduct=0xDEAD
      MatchName=* passthrough*
      AttrEventCode=-EV_ABS;-EV_KEY;-EV_MSC;-EV_REL;-EV_SW;-EV_SYN

      [Sunshine Virtual Pad]
      MatchName=Sunshine * (virtual) pad*
      AttrEventCode=-EV_ABS;-EV_KEY;-EV_MSC;-EV_REL;-EV_SW;-EV_SYN
    '';

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

    # Make avahi optional
    services.avahi.enable = lib.mkOverride 999 false;

    systemd.user.services.sunshine.serviceConfig.Environment = [
      "PATH=/run/wrappers/bin:/run/current-system/sw/bin"
    ];

    services.sunshine = {
      autoStart = true;
      openFirewall = true;

      # Set LIBINPUT_QUIRKS_DIR to origin quirks dir, so /etc/libinput/local-overrides.quirks is ignored,
      # and virtual devices are picked by headless display
      # https://gitlab.freedesktop.org/libinput/libinput/-/blob/1.27.1/src/libinput.c?ref_type=tags#L1895-1899
      # Use QT_QPA_PLATFORM=xcb or fruit give black screen
      package = pkgs.writeShellScriptBin "sunshine-sway" ''
        export LIBINPUT_QUIRKS_DIR="${lib.getOutput "out" pkgs.libinput}/share/libinput"
        export LIBSEAT_BACKEND=builtin
        export QT_QPA_PLATFORM=xcb
        export SEATD_VTBOUND=0
        export WLR_BACKENDS=headless,libinput
        export WLR_LIBINPUT_NO_DEVICES=1
        unset DBUS_SESSION_BUS_ADDRESS

        export SUNSHINE_CONFIG="$1"
        exec sway --config ${swayConfig}
      '';

      # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
      # NOTE: Set `adapter_name` to the same device for vaapi encoding, example:
      # ```
      # adapter_name = "/dev/dri/renderD129";
      # adapter_name = "/dev/dri/by-path/pci-0000:11:00.0-render";
      # ```
      # Sunshine default to `/dev/dri/renderD128`, which is not always correct, the `renderD128` is
      # not even consistent between different kernel versions.
      # Use `vainfo --display drm --device /dev/dri/renderD12x` to find out.
      # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html#adapter_name
      settings = {
        channels = 2;
        fps = "[30, 60]";
        origin_web_ui_allowed = "pc";
        resolutions = "[1280x720, 1920x1080]";
        vaapi_strict_rc_buffer = "enabled";
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
              pkgs.runCommand "${lib.nameFromURL url "."}.png" { } (
                if lib.hasSuffix ".svg" url then
                  ''
                    ${pkgs.imagemagick}/bin/magick -density 1200 -background none ${image} -resize x500 -gravity center -extent 600x800 $out
                  ''
                else
                  ''
                    ${pkgs.imagemagick}/bin/magick ${image} -background none -gravity center -extent 600x800 $out
                  ''
              );
            mkCemu =
              {
                name,
                id,
                url,
                hash,
              }:
              {
                inherit name;
                image-path = mkImage {
                  inherit url hash;
                };
                cmd = "cemu --fullscreen --title-id ${id}";
                prep-cmd = [
                  {
                    do = "${./scripts}/cemu-do.sh";
                    undo = "${./scripts}/cemu-undo.sh";
                  }
                ];
              };
            mkEden =
              {
                name,
                url,
                hash,
              }:
              {
                inherit name;
                image-path = mkImage {
                  inherit url hash;
                };
                cmd = if (name == "Eden") then "eden" else "eden -f -g $(HOME)/Games/Switch/${name}.nsp";
                # It seems inputtino make local and virtual dualsense controller the same appeared to the app, so no need to run prep-cmd
                # prep-cmd = [
                #   {
                #     do = pkgs.writeShellScript "eden-do" ''
                #       sed -e '2,$s|^|player_0_|' "$HOME/.config/eden/input/Sunshine.ini" | ${pkgs.crudini}/bin/crudini --merge "$HOME/.config/eden/qt-config.ini"
                #     '';
                #     undo = pkgs.writeShellScript "eden-undo" ''
                #       sed -e '2,$s|^|player_0_|' "$HOME/.config/eden/input/Local.ini" | ${pkgs.crudini}/bin/crudini --merge "$HOME/.config/eden/qt-config.ini"
                #     '';
                #   }
                # ];
              };
          in
          [
            {
              name = "Z_Desktop";
              image-path = mkImage {
                url = "https://github.com/LizardByte/Sunshine/raw/86188d47a7463b0f73b35de18a628353adeaa20e/sunshine.svg";
                hash = "sha256-PCdVypB7d9EtkAolVIhCTAqAWb+1VlVoZtZDSK5W5xs=";
              };
            }
            (mkCemu {
              name = "BotW";
              url = "https://assets-prd.ignimgs.com/2022/06/14/zelda-breath-of-the-wild-1655249167687.jpg?width=600";
              hash = "sha256-9AhOUgNuztTpqBLuvdTwLcJHEaKHc7F7YM6wzbzRDPk=";
              id = "00050000101c9300";
            })
            (mkEden {
              name = "NieR";
              url = "https://assets-prd.ignimgs.com/2021/12/08/nierautomata-1638924135289.jpg?width=600";
              hash = "sha256-l3Q5APq27o5wwnB1nikUJVt1P3q1dMxeLx1MadCdwRE=";
            })
            (mkEden {
              name = "REReve";
              url = "https://assets-prd.ignimgs.com/2021/12/22/resident-evil-revelations-1-button-1640136891229.jpg?width=600";
              hash = "sha256-5QUB9lirZrUk5X4mI3V/hrDsUsOKkv02ppLNheqW7mo=";
            })
            (mkEden {
              name = "TotK";
              url = "https://assets-prd.ignimgs.com/2022/09/14/zelda-tears-of-the-kingdom-button-2k-1663127818777.jpg?width=600";
              hash = "sha256-z25bcucS1YOT9WRGxNv0fzTbhVaoNItpSLvujqz7CeM=";
            })
            (mkEden {
              name = "XenoChron3";
              url = "https://assets-prd.ignimgs.com/2022/04/17/xenochron3-1650154074567.jpg?width=600";
              hash = "sha256-nJHIKkUbuLWilEqx9iR4MWaWLT0cPK3ptSeVhMH/4AE=";
            })
            (mkEden {
              name = "Eden";
              url = "https://salsa.debian.org/debian/yuzu/-/raw/b88a2a787b22e770009174e22660d0db8bfb7eb9/dist/yuzu.svg";
              hash = "sha256-JXAqoBw+YpCqeWY+M9OK6OgozheVc92pUa54+B+olU0=";
            })
          ];
      };
    };
  };
}
