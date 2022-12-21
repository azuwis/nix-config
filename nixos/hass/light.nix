{ config, lib, pkgs, ... }:

{
  services.home-assistant.config = {
    logger.logs."homeassistant.components.yeelight" = "critical";
    yeelight.devices = {
      "yeelink-light-ceiling12_mibtEA04.lan" = {
        name = "Living room";
        model = "ceiling13";
      };
      "yeelink-light-ceiling13_mibtF035.lan" = {
        name = "Primary bedroom";
        model = "ceiling13";
      };
      "yeelink-light-ceiling14_mibtE345.lan" = {
        name = "Secondary bedroom";
        model = "ceiling13";
      };
      "yeelink-light-ceiling13_mibt8675.lan" = {
        name = "Kids room";
        model = "ceiling13";
      };
      "yeelink-light-panel1_mibt8793.lan" = {
        name = "Kitchen door";
        model = "mono1";
      };
      "yeelink-light-panel1_mibt813A.lan" = {
        name = "Kitchen window";
        model = "mono1";
      };
      "yeelink-light-panel1_mibt8400.lan" = {
        name = "Bathroom";
        model = "mono1";
      };
    };
    light = [{
      platform = "group";
      name = "Kitchen";
      entities = [
        "light.kitchen_door"
        "light.kitchen_window"
      ];
    }];
  };

  hass.automations = ''
    - alias: Auto brightness day
      mode: parallel
      trigger:
        - platform: state
          entity_id: &all_lights
            - light.living_room
            - light.yeelink_fancl5_e358_light
            - light.primary_bedroom
            - light.secondary_bedroom
            - light.kids_room
            - light.kitchen_door
            - light.kitchen_window
            - light.bathroom
          to: 'on'
      condition:
        - condition: time
          after: '07:35:00'
          before: '22:35:00'
        - condition: template
          value_template: >-
            {{ state_attr(trigger.entity_id, 'brightness') < 250 }}
      action:
        service: light.turn_on
        data_template:
          entity_id: >-
            {{ trigger.entity_id }}
          brightness: 255

    - alias: Auto brightness night
      mode: parallel
      trigger:
        - platform: state
          entity_id: *all_lights
          to: 'on'
      condition:
        - condition: time
          after: '22:35:00'
          before: '07:35:00'
        - condition: template
          value_template: >-
            {{ state_attr(trigger.entity_id, 'brightness') > 5 }}
      action:
        service: light.turn_on
        data_template:
          entity_id: >-
            {{ trigger.entity_id }}
          brightness: 3

    - alias: Set brightness day
      trigger:
        - platform: time
          at: '07:35:00'
      action:
        service: light.turn_on
        data_template:
          entity_id: >-
            {{ expand(states.light) | selectattr('state', 'eq', 'on') | map(attribute='entity_id') | list }}
          brightness: 255

    - alias: Set brightness night
      trigger:
        - platform: time
          at: '22:35:00'
      action:
        service: light.turn_on
        data_template:
          entity_id: >-
            {{ expand(states.light) | selectattr('state', 'eq', 'on') | map(attribute='entity_id') | list }}
          brightness: 3

    - alias: Sync kitchen lights
      trigger:
        - platform: state
          entity_id:
            - light.kitchen_door
            - light.kitchen_window
          to: 'off'
          for: '00:00:01'
      condition:
        condition: state
        entity_id: light.kitchen
        state: 'on'
      action:
        service: light.turn_off
        data:
          entity_id: light.kitchen
  '';
}
