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
    braviatv = mkEnableOption "braviatv" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.braviatv) {
    services.home-assistant.extraPackages = ps: [ ps.pybravia ];

    hass.automations = ''
      - alias: TV living room off when light living room off
        trigger:
          - platform: state
            entity_id: light.living_room
            from: "on"
            to: "off"
          - platform: state
            entity_id: light.living_room_nightlight
            from: "on"
            to: "off"
        condition:
          - condition: sun
            after: sunset
            before: sunrise
        action:
          - service: homeassistant.update_entity
            data:
              entity_id:
                - light.living_room
                - light.living_room_nightlight
          - condition: state
            entity_id: light.living_room
            state: "off"
          - condition: state
            entity_id: light.living_room_nightlight
            state: "off"
          - service: media_player.turn_off
            data:
              entity_id: media_player.sony_kdl_55w800b
    '';
  };
}
