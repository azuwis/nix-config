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
    braviatv = mkEnableOption "braviatv";
  };

  config = mkIf (cfg.enable && cfg.braviatv) {
    services.home-assistant.extraPackages = ps: [ ps.pybravia ];

    hass.automations = ''
      - alias: TV living room off when light living room off
        triggers:
          - trigger: state
            entity_id: light.living_room
            from: "on"
            to: "off"
          - trigger: state
            entity_id: light.living_room_nightlight
            from: "on"
            to: "off"
        conditions:
          - condition: sun
            after: sunset
            before: sunrise
        actions:
          - action: homeassistant.update_entity
            target:
              entity_id:
                - light.living_room
                - light.living_room_nightlight
          - condition: state
            entity_id: light.living_room
            state: "off"
          - condition: state
            entity_id: light.living_room_nightlight
            state: "off"
          - action: media_player.turn_off
            target:
              entity_id: media_player.sony_kdl_55w800b
    '';
  };
}
