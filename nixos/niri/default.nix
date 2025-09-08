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
  cfg = config.my.niri;

  # Modify from https://github.com/YaLTeR/niri/blob/main/resources/niri-session
  # The original `systemctl --user --wait start niri.service` cause problem with `my.sunshine.enable`:
  # ```
  # niri::backend::tty: using as the render node: "/dev/dri/renderD128"
  # niri::backend::tty: device added: 57857 "/dev/dri/card1"
  # niri::backend::tty: error adding device: Failed to open device: Operation not permitted (os error 1)
  # ```
  niri-session-custom = pkgs.writeShellScriptBin "niri-session-custom" ''
    systemctl --user reset-failed
    niri --session
    systemctl --user stop niri-session.target
    systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
  '';
in
{
  options.my.niri = {
    enable = mkEnableOption "niri";

    package = mkPackageOption pkgs "niri" { };

    custom-session = mkEnableOption "niri custom session" // {
      default = config.my.wayland.session == "niri-session-custom";
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
      environment.etc."niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
        inherit (cfg) extraConfig;
        wallpaper = pkgs.wallpapers.default;
        DEFAULT_AUDIO_SINK = null;
        DEFAULT_AUDIO_SOURCE = null;
      };

      environment.systemPackages = with pkgs; [
        niri
        xwayland-satellite
      ];

      my.niri.extraConfig = lib.concatMapStrings (
        entry: "spawn-at-startup ${lib.concatMapStringsSep " " (x: "\"${x}\"") entry}\n"
      ) (builtins.attrValues config.my.wayland.startup);

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
      my.niri.extraConfig = ''
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
