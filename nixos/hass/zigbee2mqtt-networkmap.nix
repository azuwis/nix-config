{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    zigbee2mqtt-networkmap = mkEnableOption "hass" // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.zigbee2mqtt-networkmap) {
    services.home-assistant.customLovelaceModules = [ pkgs.home-assistant-custom-lovelace-modules.zigbee2mqtt-networkmap ];
  };
}
