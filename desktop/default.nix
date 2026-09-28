{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  cfg = config.desktop;
in

{
  imports = getModules [ ./. ];

  options.desktop = {
    enable = lib.mkEnableOption "desktop";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.enhance = true;
    programs.mpv.enhance = true;
  };
}
