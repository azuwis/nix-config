{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.alacritty;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.alacritty = {
    enable = lib.mkEnableOption "alacritty";

    package = lib.mkPackageOption pkgs "alacritty" { };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mkIf (cfg.settings != { }) {
      "xdg/alacritty/alacritty.toml".source = tomlFormat.generate "alacritty.toml" cfg.settings;
    };

    environment.systemPackages = [ cfg.package ];

    programs.alacritty.settings = {
      general.import = [ "${pkgs.alacritty-theme}/share/alacritty-theme/nord.toml" ];
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 15;
      };
      window = {
        decorations = "buttonless";
        dimensions = {
          columns = 106;
          lines = 29;
        };
        position = {
          x = 480;
          y = 340;
        };
      };
      selection.save_to_clipboard = true;
    };
  };
}
