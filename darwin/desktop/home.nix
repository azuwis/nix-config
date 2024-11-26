{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.desktop;
in
{
  options.my.desktop = {
    enable = mkEnableOption "desktop";
  };

  config = mkIf cfg.enable {
    my.alacritty.enable = true;
    my.mpv.enable = true;

    # Suppress login message
    home.activation.desktop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD touch ~/.hushlogin
    '';
  };
}
