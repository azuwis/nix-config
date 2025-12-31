{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    ;
  cfg = config.programs.niri;

  # Modify from https://github.com/YaLTeR/niri/blob/main/resources/niri-session
  # The original `systemctl --user --wait start niri.service` cause problem with sunshine:
  # ```
  # niri::backend::tty: using as the render node: "/dev/dri/renderD128"
  # niri::backend::tty: device added: 57857 "/dev/dri/card1"
  # niri::backend::tty: error adding device: Failed to open device: Operation not permitted (os error 1)
  # ```
  niri-session-custom = pkgs.writeShellScriptBin "niri-session-custom" ''
    systemctl --user reset-failed
    systemctl --user import-environment
    dbus-update-activation-environment --all
    niri --session
    systemctl --user stop niri-session.target
    systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
  '';
in
{
  disabledModules = [ "programs/wayland/niri.nix" ];

  options.programs.niri = {
    enable = mkEnableOption "niri";

    package = mkPackageOption pkgs "niri" { };

    custom-session = mkEnableOption "niri custom session" // {
      default = config.programs.wayland.session == "niri-session-custom";
    };

    # No specific input device configuration yet, at least provide per-host setting our own
    # https://github.com/YaLTeR/niri/issues/371
    settings.input.mouse = mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "natural-scroll"
      ];
    };

    extraConfig = mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (import (modulesPath + "/programs/wayland/wayland-session.nix") {
      inherit lib pkgs;
    })

    {
      # https://github.com/YaLTeR/niri/raw/refs/tags/v25.11/resources/default-config.kdl
      environment.etc."niri/config.kdl".source =
        pkgs.runCommand "niri-default-config.kdl" { preferLocalBuild = true; }
          ''
            sed -e '/ Mod+T /d' -e '/spawn-at-startup "waybar"/d' ${./default-config.kdl} > $out
            echo >> $out
            echo 'include "custom.kdl"' >> $out
          '';

      environment.etc."niri/custom.kdl".source = pkgs.replaceVars ./custom.kdl {
        inherit (cfg) extraConfig;
        wallpaper = pkgs.wallpapers.default;
        wallpaper-blur = pkgs.runCommand "wallpaper-blur.jpg" { preferLocalBuild = true; } ''
          ${lib.getExe pkgs.imagemagick} ${pkgs.wallpapers.default} -blur 0x12 $out
        '';
        input_mouse = lib.concatStringsSep "\n        " cfg.settings.input.mouse;
      };

      environment.systemPackages = with pkgs; [
        niri
        swww
        playerctl
        xwayland-satellite
      ];

      programs.niri.extraConfig = lib.concatMapStrings (
        entry: "spawn-at-startup ${lib.concatMapStringsSep " " (x: "\"${x}\"") entry}\n"
      ) (builtins.attrValues config.programs.wayland.startup);

      programs.wayland.enable = true;

      systemd.packages = [ cfg.package ];

      xdg.portal = {
        enable = true;
        # Prefer gtk portal for FileChooser, when gnome portal is enabled and nautilus is not installed,
        # `Delegated FileChooser call failed: The name org.gnome.Nautilus was not provided by any .service files`,
        # see https://github.com/NixOS/nixpkgs/pull/360101
        config.niri."org.freedesktop.impl.portal.FileChooser" = "gtk";
        # For screen capture
        # extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        configPackages = [ cfg.package ];
      };
    }

    (mkIf cfg.custom-session {
      programs.niri.extraConfig = ''
        spawn-at-startup "systemctl" "--user" "start" "niri-session.target"
      '';

      environment.systemPackages = [ niri-session-custom ];

      systemd.user.targets.niri-session = {
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
    })
  ]);
}
