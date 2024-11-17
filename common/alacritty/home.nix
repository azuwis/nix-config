{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.alacritty;
in
{
  options.my.alacritty = {
    enable = mkEnableOption "alacritty";
  };

  config = mkIf cfg.enable {
    programs.alacritty.enable = true;
    programs.alacritty.settings = {
      general.import = [ "${pkgs.alacritty-theme}/nord.toml" ];
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
