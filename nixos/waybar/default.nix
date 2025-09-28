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
    settings = lib.mkOption {
      type = jsonFormat.type;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."xdg/waybar/config".source = jsonFormat.generate "waybar-config.json" cfg.settings;

    environment.etc."xdg/waybar/style.css".source = ./style.css;

    programs.waybar.settings = [
      {
        layer = "top";
        height = 26;
        modules-left = [
          "niri/workspaces"
          "sway/workspaces"
        ];
        modules-center = [
          "niri/window"
          "sway/window"
        ];
        modules-right = [
          "custom/network"
          "cpu"
          "memory"
          "pulseaudio"
          "clock"
        ];
        "niri/window" = {
          format = "{app_id}";
        };
        "sway/window" = {
          format = "{app_id}";
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
