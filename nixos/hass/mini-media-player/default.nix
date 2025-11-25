{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.hass;
in
{
  options.services.hass = {
    mini-media-player = mkEnableOption "hass";
  };

  config = mkIf (cfg.enable && cfg.mini-media-player) {
    services.home-assistant.customLovelaceModules = [
      pkgs.home-assistant-custom-lovelace-modules.mini-media-player
    ];
  };
}
