{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.nibar;
in
{
  options.my.nibar = {
    enable = mkEnableOption (mdDoc "nibar");
  };

  config = mkIf cfg.enable {
    home.activation.ubersicht = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ubersicht_widgets=~/Library/Application\ Support/Übersicht/widgets
      mkdir -p "$ubersicht_widgets"
      rm -f "$ubersicht_widgets/GettingStarted.jsx"
      rm -f "$ubersicht_widgets/logo.png"
      if [ ! -e "$ubersicht_widgets/nibar" ] || [ "$(readlink "$ubersicht_widgets/nibar")" != "${pkgs.nibar}" ]
      then
        ln -sfn "${pkgs.nibar}" "$ubersicht_widgets/nibar"
      fi
    '';
  };
}
