{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.yambar;

  # ifaces = builtins.attrNames config.networking.interfaces;
  # ens = builtins.filter (name: (builtins.match "^e.*" name) != null) ifaces;
  # en = if ens != [] then builtins.elemAt ens 0 else null;
  msgcmd = if config.my.sway.enable then "swaymsg" else "i3-msg";
in
{
  options.my.yambar = {
    enable = mkEnableOption "yambar";
    scale = mkOption {
      type = types.int;
      default = 1;
    };
  };

  config = mkIf cfg.enable {
    programs.yambar.enable = true;

    programs.yambar.package = pkgs.yambar-git;

    programs.yambar.settings.bar = {
      layer = "top";
      location = "top";
      height = 26 * cfg.scale;
      background = "2E3440FF";
      font = "monospace:pixelsize=${builtins.toString (16 * cfg.scale)}";
      spacing = 6 * cfg.scale;
      margin = 12 * cfg.scale;
      left = [
        {
          i3 = {
            sort = "ascending";
            content."".map =
              let
                default = {
                  text = "{name}";
                  margin = 6 * cfg.scale;
                  on-click = "${msgcmd} --quiet workspace {name}";
                };
                focused.foreground = "EBCB8BFF";
                urgent = {
                  foreground = "000000FF";
                  deco.stack = [ { background.color = "BF616AFF"; } ];
                };
                underline.underline = {
                  size = 2;
                  color = "81A1C1FF";
                };
              in
              {
                default.string = default;
                conditions = {
                  "state == focused".string = default // focused;
                  "state == urgent".string = default // urgent;
                };
              };
          };
        }
        {
          niri-workspaces = {
            content.map =
              let
                default = {
                  margin = 6 * cfg.scale;
                  text = "{id}";
                };
              in
              {
                conditions = {
                  active.string = default // {
                    foreground = "EBCB8BFF";
                  };
                  "~empty".string = default;
                };
              };
          };
        }
      ];
      center = [
        {
          foreign-toplevel.content.map.conditions = {
            "~activated".empty = { };
            activated.string.text = "{app-id}";
          };
        }
      ];
      right = [
        {
          network = {
            poll-interval = 10000;
            content.map.conditions."state == up" = [
              {
                string = {
                  text = "";
                  right-margin = 4 * cfg.scale;
                };
              }
              {
                map = {
                  default.string.text = "{dl-speed:/8192:.0}K";
                  conditions."dl-speed >= 8388608".string.text = "{dl-speed:/8388608:.1}M";
                };
              }
              {
                string = {
                  text = "";
                  left-margin = 6 * cfg.scale;
                  right-margin = 4 * cfg.scale;
                };
              }
              {
                map = {
                  default.string.text = "{ul-speed:/8192:.0}K";
                  conditions."ul-speed >= 8388608".string.text = "{ul-speed:/8388608:.1}M";
                };
              }
            ];
          };
        }
        {
          cpu = {
            poll-interval = 10000;
            content.map.conditions."id < 0" = [
              {
                string = {
                  text = "󰓅";
                  right-margin = 4 * cfg.scale;
                };
              }
              { string.text = "{cpu}%"; }
            ];
          };
        }
        {
          mem = {
            poll-interval = 10000;
            content = [
              {
                string = {
                  text = "󰍛";
                  right-margin = 4 * cfg.scale;
                };
              }
              { string.text = "{free:gb}G"; }
            ];
          };
        }
        {
          pulse.content = [
            {
              map.conditions = {
                sink_muted.string = {
                  text = "󰖁";
                  right-margin = 4 * cfg.scale;
                };
                "~sink_muted".string = {
                  text = "󰕾";
                  right-margin = 4 * cfg.scale;
                };
              };
            }
            { string.text = "{sink_percent}"; }
          ];
        }
        {
          clock = {
            date-format = "%a %m-%d";
            content = [
              {
                string = {
                  text = "";
                  right-margin = 4 * cfg.scale;
                };
              }
              { string.text = "{date} {time}"; }
            ];
          };
        }
      ];
    };

    wayland.windowManager.sway.config.bars = [ ];

    xsession.windowManager.i3.config.bars = [ ];

    systemd.user.services.yambar = {
      Unit = {
        After = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${config.programs.yambar.package}/bin/yambar";
        Restart = "on-failure";
        RestartSec = "1s";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
