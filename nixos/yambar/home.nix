{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.yambar;

  # ifaces = builtins.attrNames config.networking.interfaces;
  # ens = builtins.filter (name: (builtins.match "^e.*" name) != null) ifaces;
  # en = if ens != [] then builtins.elemAt ens 0 else null;
  msgcmd = if config.my.sway.enable then "swaymsg" else "i3-msg";
in
{
  options.my.yambar = {
    enable = mkEnableOption "yambar";
  };

  config = mkIf cfg.enable {
    programs.yambar.enable = true;

    programs.yambar.package = pkgs.yambar-git;

    programs.yambar.settings.bar = {
      location = "top";
      height = 26;
      background = "2E3440FF";
      font = "monospace:pixelsize=16";
      spacing = 6;
      margin = 12;
      left = [
        {
          i3 = {
            sort = "ascending";
            content."".map =
              let
                default = {
                  text = "{name}";
                  margin = 6;
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
            content.map.conditions."name == eno1 || name == wlo1" = [
              {
                string = {
                  text = "";
                  right-margin = 4;
                };
              }
              {
                map = {
                  default.string.text = "{dl-speed:kiB:.0}K";
                  conditions."dl-speed >= 8388608".string.text = "{dl-speed:miB:.1}M";
                };
              }
              {
                string = {
                  text = "";
                  left-margin = 6;
                  right-margin = 4;
                };
              }
              {
                map = {
                  default.string.text = "{ul-speed:kiB:.0}K";
                  conditions."ul-speed >= 8388608".string.text = "{ul-speed:miB:.1}M";
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
                  right-margin = 4;
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
                  right-margin = 4;
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
                  right-margin = 4;
                };
                "~sink_muted".string = {
                  text = "󰕾";
                  right-margin = 4;
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
                  right-margin = 4;
                };
              }
              { string.text = "{date} {time}"; }
            ];
          };
        }
      ];
    };

    wayland.windowManager.sway.config = {
      bars = [ ];
      startup = [ { command = "yambar --log-level=error"; } ];
    };

    xsession.windowManager.i3.config = {
      bars = [ ];
      startup = [ { command = "yambar --log-level=error"; } ];
    };

    # systemd.user.services.yambar = {
    #   Unit = {
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #
    #   Service = {
    #     ExecStart = "${pkgs.yambar}/bin/yambar --config=${config} --log-level=error";
    #     Environment = "PATH=/run/current-system/sw/bin";
    #     Restart = "on-failure";
    #   };
    #
    #   Install = { WantedBy = [ "graphical-session.target" ]; };
    # };
  };
}
