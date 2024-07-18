{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.foot;
in
{
  options.my.foot = {
    enable = mkEnableOption "foot";
  };

  config = mkIf cfg.enable {
    my.sway.tmenu = "footclient --app-id tmenu --window-size-chars 50x10";

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = lib.mkDefault "monospace:pixelsize=20";
          include = "${lib.getOutput "themes" pkgs.foot}/share/foot/themes/nord";
          term = "xterm-256color";
        };
      };
    };

    wayland.windowManager.sway.config = {
      startup = [ { command = "foot --server --log-level=error"; } ];
      terminal = "footclient";
    };
  };
}
