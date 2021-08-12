{ config, pkgs, ... }:

{
  fonts.enableFontDir = true;
  fonts.fonts = [ pkgs.jetbrains-mono ];
  homebrew.casks = [ "ubersicht" ];
  services.yabai.config.external_bar = "main:28:0";
  system.activationScripts.postActivation.text = ''
    ln -sfn ${pkgs.yabai}/bin/yabai /usr/local/bin/yabai
  '';
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

}
