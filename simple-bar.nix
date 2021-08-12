{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = super: {
    simple-bar = pkgs.callPackage ./pkgs/simple-bar {};
  };
  home-manager.users."${config.my.user}" = {
    home.packages = [ pkgs.simple-bar ];
    home.file."Library/Application Support/Übersicht/widgets/simple-bar".source = pkgs.simple-bar;
    home.activation.ubersicht = ''
      rm -f ~/Library/Application\ Support/Übersicht/widgets/GettingStarted.jsx
      rm -f ~/Library/Application\ Support/Übersicht/widgets/logo.png
    '';
  };
  homebrew.casks = [ "ubersicht" ];
  services.yabai.config.external_bar = "main:28:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
