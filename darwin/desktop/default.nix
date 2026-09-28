{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop;
in

{
  config = lib.mkIf cfg.enable {
    # programs.emacs.enable = true;
    # programs.hammerspoon.enable = true;

    programs.rime.enable = true;
    programs.thunderbird.enhance = true;
    services.rift.enhance = true;
    services.sketchybar.enhance = true;
    # services.skhd.enhance = true;
    # services.yabai.enhance = true;

    # Suppress login message
    system.activationScripts.postActivation.text = ''
      touch ${config.system.primaryUserHome}/.hushlogin
    '';
  };
}
