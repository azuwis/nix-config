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
    braviatv = mkEnableOption "braviatv";
  };

  config = mkIf (cfg.enable && cfg.braviatv) {
    # Keep icon unchanged across on/off states
    services.home-assistant.config.homeassistant.customize."media_player.sony_kdl_55w800b".icon =
      "mdi:television";

    # https://github.com/home-assistant/core/issues/170121
    services.home-assistant.config.ssdp = { };

    services.home-assistant.extraPackages = ps: [ ps.pybravia ];

    services.hass.automations = ''
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
