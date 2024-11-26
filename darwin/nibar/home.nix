{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.nibar;
in
{
  options.my.nibar = {
    enable = mkEnableOption "nibar";
  };

  config = mkIf cfg.enable {
    home.activation.ubersicht = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ubersicht_widgets=~/Library/Application\ Support/Übersicht/widgets
      $DRY_RUN_CMD mkdir -p "$ubersicht_widgets"
      $DRY_RUN_CMD rm -f "$ubersicht_widgets/GettingStarted.jsx"
      $DRY_RUN_CMD rm -f "$ubersicht_widgets/logo.png"
      if [ ! -e "$ubersicht_widgets/nibar" ] || [ "$(readlink "$ubersicht_widgets/nibar")" != "${pkgs.nibar}" ]
      then
        $DRY_RUN_CMD ln -sfn "${pkgs.nibar}" "$ubersicht_widgets/nibar"
      fi
    '';
  };
}
