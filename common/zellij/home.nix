{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.zellij;
in
{
  options.my.zellij = {
    enable = mkEnableOption "zellij";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      # enableZshIntegration = true;
      settings = {
        default_layout = "compact";
        pane_frames = false;
        simplified_ui = true;
        theme = "nord";
        ui.pane_frames = {
          hide_session_name = true;
          rounded_corners = true;
        };
      };
    };
  };
}
