{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.programs.wayland) scale;
  cfg = config.programs.yambar;
  yamlFormat = pkgs.formats.yaml { };

  # ifaces = builtins.attrNames config.networking.interfaces;
  # ens = builtins.filter (name: (builtins.match "^e.*" name) != null) ifaces;
  # en = if ens != [] then builtins.elemAt ens 0 else null;
  msgcmd = if config.programs.sway.enable then "swaymsg" else "i3-msg";
in
{
  options.programs.yambar = {
    enable = lib.mkEnableOption "yambar";

    package = lib.mkPackageOption pkgs "yambar-git" { };

    settings = lib.mkOption {
      type = yamlFormat.type;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."xdg/yambar/config.yml".source =
      yamlFormat.generate "yambar-config.yml" cfg.settings;

    environment.systemPackages = [
      (pkgs.wrapper {
        package = cfg.package;
        env.XDG_CONFIG_HOME = "/etc/xdg";
      })
    ];

    programs.wayland.startup.yambar = [ "yambar" ];

    programs.yambar.settings.bar = {
      layer = "top";
      location = "top";
      height = 26 * scale;
      background = "2E3440FF";
      font = "monospace:pixelsize=${toString (16 * scale)}";
      spacing = 6 * scale;
      margin = 12 * scale;
      left = [
        {
          i3 = {
            sort = "ascending";
            content."".map =
              let
                default = {
                  text = "{name}";
                  margin = 6 * scale;
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
                  margin = 6 * scale;
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
            # `kind = ""` matches non-virtual interfaces
            content.map.conditions."state == up && kind == \"\"" = [
              {
                string = {
                  text = "";
                  right-margin = 4 * scale;
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
                  left-margin = 6 * scale;
                  right-margin = 4 * scale;
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
                  right-margin = 4 * scale;
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
                  right-margin = 4 * scale;
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
                  right-margin = 4 * scale;
                };
                "~sink_muted".string = {
                  text = "󰕾";
                  right-margin = 4 * scale;
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
                  right-margin = 4 * scale;
                };
              }
              { string.text = "{date} {time}"; }
            ];
          };
        }
      ];
    };
  };
}
