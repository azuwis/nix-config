{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.niri;
in

{
  options.programs.niri = {
    enhance = lib.mkEnableOption "and enhance niri";

    # No specific input device configuration yet, at least provide per-host setting our own
    # https://github.com/YaLTeR/niri/issues/371
    settings.input.mouse = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "natural-scroll"
      ];
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enhance {
    programs.niri.enable = true;
    programs.niri.useNautilus = false;
    services.gnome.gnome-keyring.enable = false;
    # `programs.niri.enable` add xdg-desktop-portal-gnome for screencast, force disable:
    # xdg.portal.extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-gtk ];
    # or disable xdg portal entirely:
    # xdg.portal.enable = lib.mkForce false;

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
      swww
      playerctl
      xwayland-satellite
    ];

    programs.niri.extraConfig = lib.concatMapStrings (
      entry: "spawn-at-startup ${lib.concatMapStringsSep " " (x: "\"${x}\"") entry}\n"
    ) (builtins.attrValues config.programs.wayland.startup);

    programs.wayland.enable = true;
  };
}
