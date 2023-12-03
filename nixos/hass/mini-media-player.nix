{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    mini-media-player = mkEnableOption "hass" // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.mini-media-player) {
    services.home-assistant.customLovelaceModules = [ pkgs.home-assistant-custom-lovelace-modules.mini-media-player ];
  };
}
