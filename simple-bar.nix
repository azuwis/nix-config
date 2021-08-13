{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = super: {
    simple-bar = pkgs.callPackage ./pkgs/simple-bar {};
  };
  home-manager.users."${config.my.user}" = {
    home.packages = [ pkgs.simple-bar ];
    home.activation.ubersicht = ''
      ubersicht_widgets=~/Library/Application\ Support/Übersicht/widgets
      mkdir -p "$ubersicht_widgets"
      rm -f "$ubersicht_widgets/GettingStarted.jsx"
      rm -f "$ubersicht_widgets/logo.png"
      if [ ! -e "$ubersicht_widgets/simple-bar" ] || [ "$(readlink "$ubersicht_widgets/simple-bar")" != "${pkgs.simple-bar}" ]
      then
        ln -sfn "${pkgs.simple-bar}" "$ubersicht_widgets/simple-bar"
      fi
    '';
  };
  homebrew.casks = [ "ubersicht" ];
  services.yabai.config.external_bar = "main:28:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
