{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.waybar;
in
{
  options.my.waybar = {
    enable = mkEnableOption "waybar";
  };

  config = mkIf cfg.enable {
    programs.waybar.enable = true;
    programs.waybar.settings = [
      {
        layer = "top";
        height = 26;
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "custom/network"
          "cpu"
          "memory"
          "pulseaudio"
          "clock"
        ];
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
    programs.waybar.style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: monospace;
          font-size: 16px;
      }

      window#waybar {
          background: #2e3440;
          color: #ffffff;
      }

      #workspaces button {
          padding: 0 3px;
          background: transparent;
          color: #ffffff;
      }

      #workspaces button.focused {
          color: #ebcb8b;
      }

      #workspaces button.urgent {
          color: #bf616a;
      }

      #clock,
      #cpu,
      #custom-network,
      #memory,
      #pulseaudio,
      #workspaces {
          padding: 0 6px;
      }
    '';

    wayland.windowManager.sway.config = {
      bars = [ ];
      startup = [ { command = "waybar"; } ];
    };
  };
}
