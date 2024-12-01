{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    gree = mkEnableOption "gree";
  };

  config = mkIf (cfg.enable && cfg.gree) {
    services.home-assistant.customComponents = [ pkgs.gree ];

    services.home-assistant.config = {
      climate = [
        {
          name = "Living room";
          platform = "gree";
          host = "192.168.2.228";
          mac = "94:24:b8:12:3f:e9";
          target_temp_step = 1;
          temp_sensor = "sensor.1775bcf17c0e_temperature";
          max_online_attempts = 5;
        }
      ];

      # logger.logs."custom_components.gree" = "debug";
      # logger.logs."custom_components.gree.climate" = "debug";
    };

    hass.automations = ''
      - alias: Climate living room off when light living room off
        triggers:
          - trigger: state
            entity_id: light.living_room
            to: "off"
        conditions:
          - condition: sun
            after: sunset
            before: sunrise
        actions:
          - action: climate.turn_off
            target:
              entity_id: climate.living_room
    '';
  };
}
