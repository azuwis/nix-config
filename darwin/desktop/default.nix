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
    # my.emacs.enable = true;
    # my.hammerspoon.enable = true;
    my.rime.enable = true;

    programs.firefox.enable = true;
    programs.mpv.enable = true;

    # Suppress login message
    system.activationScripts.postActivation.text = ''
      touch ${config.system.primaryUserHome}/.hushlogin
    '';
  };
}
