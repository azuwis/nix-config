{
  config,
  lib,
  pkgs,
  ...
}:

# NOTE: Enable `Optimize mouse for remote desktop instead of games` in Moonlight,
# or the mouse cursor will be very fast when using Dualsense's touchpad

# Moonlight controller combo
# Select+L1+R1+Start: quit
# Select+L1+R1+X(□): stats
# https://github.com/moonlight-stream/moonlight-qt/blob/296387345d9d4ef124d69e8c19f83f393ff4a8ea/app/streaming/input/gamepad.cpp#L366-L396

let
  cfg = config.services.sunshine;

  swayConfig = pkgs.replaceVarsWith {
    name = "sunshine-sway.conf";
    src = ../sway/config;
    replacements = {
      inherit (config.programs.wayland) terminal;
      wallpaper = pkgs.wallpapers.default;
      # swaymsg -s /run/user/*/sway-ipc.*.sock --pretty --type get_inputs | awk '/Identifier:/ {print $2}'
      extraConfig = ''
        default_border normal
        default_floating_border normal
        bindsym BTN_RIGHT kill

        seat seat0 fallback false
        # seat seat0 attach "1356:3302:Sunshine_PS5_(virtual)_pad_Touchpad"
        seat seat0 attach "48879:57005:Keyboard_passthrough"
        seat seat0 attach "48879:57005:Mouse_passthrough"
        seat seat0 attach "48879:57005:Mouse_passthrough_(absolute)"
        seat seat0 attach "48879:57005:Pen_passthrough"
        seat seat0 attach "48879:57005:Touch_passthrough"

        output HEADLESS-1 mode ${cfg.mode}
        output HEADLESS-1 scale ${cfg.scale}

        assign [app_id="^sunshine-terminal$"] 4
        exec foot --app-id=sunshine-terminal

        # Import the most important environment variables into the D-Bus, for xdg-desktop-portal-gtk
        # and others, see also /etc/sway/config.d/nixos.conf
        # Do not import those variables to systemd, it will affect the real display
        exec dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP

        exec ${lib.getExe (pkgs.sunshine.override { inherit (cfg) cudaSupport; })} "$SUNSHINE_CONFIG"
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
    enhance = lib.mkEnableOption "and enhance sunshine";

    cudaSupport = lib.mkEnableOption "cuda";

    # MangoHud cause vulkan app to segfault as of version 0.8.1
    mangohud = lib.mkEnableOption "mangohud";

    mode = lib.mkOption {
      type = lib.types.str;
      default = "3840x2160@60Hz";
    };

    scale = lib.mkOption {
      type = lib.types.str;
      default = "2";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = config.my.user;
    };
  };

  config = lib.mkIf cfg.enhance {
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

    environment.systemPackages = lib.mkIf cfg.mangohud [ pkgs.mangohud ];

    hardware.uinput.enable = true;
    users.users.${cfg.user}.extraGroups = [ "uinput" ];

    # udevadm info -a [/sys/device/...|/dev/...]
    # udevadm monitor --environment --property --udev
    # https://github.com/LizardByte/Sunshine/blob/master/src_assets/linux/misc/60-sunshine.rules
    # KERNEL=="hidraw*", ATTRS{name}=="Sunshine PS5 (virtual) pad", GROUP="input", MODE="0660", TAG+="uaccess"
    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="uhid", GROUP="uinput", MODE="0660"
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Sunshine * (virtual) pad*", MODE="0660", GROUP="uinput"
      SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="beef", ATTRS{id/product}=="dead", ATTRS{name}=="* passthrough*", MODE="0660", GROUP="uinput"
    '';

    programs.sway.enhance = true;

    # Make avahi optional
    services.avahi.enable = lib.mkOverride 999 false;

    systemd.user.services.sunshine.serviceConfig.Environment = [
      "PATH=/run/wrappers/bin:/run/current-system/sw/bin"
    ];

    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;

      package = pkgs.writeShellScriptBin "sunshine-sway" ''
        # Set LIBINPUT_QUIRKS_DIR to origin quirks dir, so /etc/libinput/local-overrides.quirks is ignored,
        # and sunehine virtual devices are picked by headless display
        # https://gitlab.freedesktop.org/libinput/libinput/-/blob/1.27.1/src/libinput.c?ref_type=tags#L1895-1899
        export LIBINPUT_QUIRKS_DIR="${lib.getOutput "out" pkgs.libinput}/share/libinput"

        # Virtual wayland display setup
        export LIBSEAT_BACKEND=builtin
        export SEATD_VTBOUND=0
        export WLR_BACKENDS=headless,libinput
        export WLR_LIBINPUT_NO_DEVICES=1

        # Eden recommand xcb backend, good old fruit give black screen without it
        export QT_QPA_PLATFORM=xcb

        # The wrapped sway automatically use dbus-run-session if DBUS_SESSION_BUS_ADDRESS unset
        # https://github.com/NixOS/nixpkgs/blob/c5d2fe68dd3fdfe532d493d4fb8d169e4fe237e9/pkgs/by-name/sw/sway/package.nix#L41-L46
        unset DBUS_SESSION_BUS_ADDRESS

        # The WM on real display like niri-session may import the following env vars to systemd
        # user service manager, sunshine run as systemd user service will inherit them.
        # Need to unset before calling sway/dbus-run-session, or some processes like
        # xdg-desktop-portal-gtk will use the wrong DISPLAY
        unset DISPLAY
        unset NIRI_SOCKET
        unset WAYLAND_DISPLAY
        unset XDG_CURRENT_DESKTOP
        unset XDG_SEAT
        unset XDG_SESSION_ID
        unset XDG_SESSION_TYPE
        unset XDG_VTNR

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
        global_prep_cmd =
          let
            do = pkgs.writeShellScript "sunshine-do" ''
              scale=$((SUNSHINE_CLIENT_WIDTH * 10 / 1920))
              scale="''${scale:0:''${#scale}-1}.''${scale: -1}"
              swaymsg output HEADLESS-1 mode "$SUNSHINE_CLIENT_WIDTH"x"$SUNSHINE_CLIENT_HEIGHT"@"$SUNSHINE_CLIENT_FPS"Hz
              swaymsg output HEADLESS-1 scale "$scale"
            '';
            undo = pkgs.writeShellScript "sunshine-undo" ''
              swaymsg output HEADLESS-1 mode ${cfg.mode}
              swaymsg output HEADLESS-1 scale ${cfg.scale}
            '';
          in
          ''[{"do":"${do}","undo":"${undo}"}]'';
        origin_web_ui_allowed = "pc";
        resolutions = "[1280x720, 1920x1080, 3840x2160]";
        vaapi_strict_rc_buffer = "enabled";
      };

      applications = {
        # NOTE: The Z_Desktop app will not pickup env set here
        env = {
          # Moonlight see no apps if env not set, at least keep an empty env
        }
        // lib.optionalAttrs cfg.mangohud {
          MANGOHUD = "1";
          MANGOHUD_CONFIG = "preset=1+2+-1+3+4+0";
        };
        apps =
          let
            mkImage =
              {
                url,
                hash,
                resize ? "500x",
              }:
              let
                image = pkgs.fetchurl { inherit url hash; };
              in
              pkgs.runCommand "${lib.nameFromURL url "."}.png" { preferLocalBuild = true; } ''
                ${pkgs.imagemagick}/bin/magick -density 1200 -background none ${image} -resize ${resize} -gravity center -extent 600x800 $out
              '';
            mkCemu =
              {
                name,
                id ? "",
                image,
              }:
              {
                inherit name;
                image-path = image;
                cmd = if name == "Cemu" then "cemu" else "cemu --fullscreen --title-id ${id}";
                # prep-cmd = [
                #   {
                #     do = "${./scripts}/cemu-do.sh";
                #     undo = "${./scripts}/cemu-undo.sh";
                #   }
                # ];
              };
            mkEden =
              {
                name,
                image,
              }:
              {
                inherit name;
                image-path = image;
                cmd = if name == "Eden" then "eden" else "eden -f -g $(HOME)/Games/Switch/${name}.nsp";
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
              name = "Cemu";
              image = mkImage {
                # https://www.steamgriddb.com/icon/31790
                url = "https://cdn2.steamgriddb.com/icon/3b11e049d4d051954f4c8b742a2b306e.png";
                hash = "sha256-uva+yvakvtSirqtWCYhlrxtTTFb7a8gSkeBSJTX8f2s=";
                resize = "600x";
              };
            })
            (mkEden {
              name = "Eden";
              image = mkImage {
                url = "https://salsa.debian.org/debian/yuzu/-/raw/b88a2a787b22e770009174e22660d0db8bfb7eb9/dist/yuzu.svg";
                hash = "sha256-JXAqoBw+YpCqeWY+M9OK6OgozheVc92pUa54+B+olU0=";
              };
            })
          ];
      };
    };
  };
}
