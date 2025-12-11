{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.waybar;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.waybar = {
    enhance = lib.mkEnableOption "and enhance waybar";
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enhance {
    environment.etc."xdg/waybar/config".source = jsonFormat.generate "waybar-config.json" cfg.settings;

    environment.etc."xdg/waybar/style.css".source = ./style.css;

    programs.waybar.enable = true;
    programs.waybar.settings =
      let
        window = {
          format = "{app_id}";
          rewrite = {
            # https://www.nerdfonts.com/cheat-sheet
            # Need an extra space so waybar dont crop it
            "(.*)" = "<span text-transform='capitalize'>$1</span>";
            "(Info\\.Cemu\\.)?Cemu" = "󰜭 ";
            "(com\\.moonlight_stream\\.)?Moonlight" = "󰺵 ";
            "(dev\\.eden_emu\\.)?eden" = "󰟡 ";
            "foot(client)?|Sunshine-Terminal" = " ";
            chromium-browser = " ";
            firefox = " ";
            mpv = " ";
          };
        };
      in
      [
        {
          layer = "top";
          height = 26;
          modules-left = [
            "custom/menu"
            "niri/window"
            "sway/window"
            "custom/dot"
          ];
          modules-center = [
            "niri/workspaces"
            "sway/workspaces"
          ];
          modules-right = [
            "custom/network"
            "cpu"
            "memory"
            "pulseaudio"
            "clock"
          ];
          "custom/menu" = {
            format = " ";
            on-click = "fuzzel";
            tooltip = false;
          };
          "niri/window" = window;
          "sway/window" = window;
          "custom/dot" = {
            format = "<span size='x-small' rise='-21pt'> </span>";
            tooltip = false;
          };
          "niri/workspaces" = {
            cursor = true;
            format = "{icon}";
            format-icons = {
              default = "";
            };
          };
          "sway/workspaces" = {
            # waybar crash in Niri if cursor is true here
            # cursor = true;
            format = "{icon}";
            format-icons = {
              default = "";
            };
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
            };
          };
          "custom/network" = {
            exec = "${./netspeed.sh}";
          };
          cpu = {
            format = "󰓅 {usage}%";
          };
          memory = {
            format = "󰍛 {percentage}%";
          };
          pulseaudio = {
            format = "󰕾 {volume}%";
            format-muted = "󰖁 {volume}%";
          };
          clock = {
            format = " {:%a %m-%d %H:%M}";
          };
        }
      ];

    programs.wayland.startup.waybar = [ "waybar" ];

    systemd.user.services.waybar.enable = false;
  };
}
