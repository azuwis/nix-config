{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    rev = "e267e744a08ccee572376b3f120767dd4bfca21a";
    sha256 = "sha256-rrOUFSs4gHEXZcCB2aFkP2Vt1lyHvnmp2b60A6oJCvc=";
  };
in
{
  options.my.hass = {
    gree = mkEnableOption (mdDoc "gree") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.gree) {
    hass.file."custom_components/gree".source = "${component}/custom_components/gree";

    services.home-assistant.config = {
      climate = [{
        name = "Living room";
        platform = "gree";
        host = "192.168.2.228";
        mac = "94:24:b8:12:3f:e9";
        target_temp_step = 1;
        temp_sensor = "sensor.1775bcf17c0e_temperature";
      }];

      # logger.logs."custom_components.gree" = "debug";
      # logger.logs."custom_components.gree.climate" = "debug";
    };

  };
}
