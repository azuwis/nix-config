{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = mkEnableOption "desktop";
  };

  config = mkIf cfg.enable {
    # programs.emacs.enable = true;
    # programs.hammerspoon.enable = true;

    programs.firefox.enable = true;
    programs.mpv.enable = true;
    programs.rime.enable = true;

    # Suppress login message
    system.activationScripts.postActivation.text = ''
      touch ${config.system.primaryUserHome}/.hushlogin
    '';
  };
}
