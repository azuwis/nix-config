{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
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
}

else

{
  homebrew.casks = [ "ubersicht" ];
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
