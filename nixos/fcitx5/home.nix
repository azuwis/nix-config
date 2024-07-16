{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.fcitx5;
in
{
  options.my.fcitx5 = {
    enable = mkEnableOption "fcitx5";
  };

  config = mkIf cfg.enable {
    # home.activation.fcitx5 = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   ${fcitx5}/bin/fcitx5-remote -r || true
    # '';
    xdg.configFile.fcitx5.source = ./config;
    wayland.windowManager.sway.config.startup = [ { command = "fcitx5"; } ];
    xsession.windowManager.i3.config.startup = [ { command = "fcitx5"; } ];
  };
}
