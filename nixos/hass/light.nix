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
      };
      "yeelink-light-panel1_mibt813A.lan" = {
        name = "Kitchen window";
      };
      "yeelink-light-panel1_mibt8400.lan" = {
        name = "Bathroom";
      };
    };
    homeassistant.customize = let customize = {
      supported_color_modes = [ "brightness" ];
    };
    in {
      "light.kitchen".icon = "mdi:lightbulb";
      "light.bathroom" = customize;
      "light.kitchen_door" = customize;
      "light.kitchen_window" = customize;
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
    - alias: Light brightness
      mode: parallel
      trigger:
        - platform: state
          entity_id:
            - light.living_room
            - light.1660a6874242f000_group
            - light.16609ab46d42b000_group
            - light.1697cc678402b000_group
            - light.yeelink_fancl5_e358_light
            - light.primary_bedroom
            - light.secondary_bedroom
            - light.kids_room
            - light.kitchen_door
            - light.kitchen_window
            - light.bathroom
          to: "on"
      variables:
        brightness: &brightness >-
          {% set now = now() %}
          {% if now > today_at("22:35") %}
            128
          {% elif now < today_at("7:35") %}
            3
          {% else %}
            255
          {% endif %}
        color_temp: >-
          {{ "color_temp" in state_attr(trigger.entity_id, "supported_color_modes") }}
        kelvin: 5235
      condition:
        - condition: template
          value_template: >-
            {{ (state_attr(trigger.entity_id, "brightness") != brightness) or
               (color_temp and (state_attr(trigger.entity_id, "color_temp_kelvin") != kelvin))
            }}
      action:
        service: light.turn_on
        target:
          entity_id: "{{ trigger.entity_id }}"
        data: >-
          {"brightness": {{ brightness }}{% if color_temp %}, "kelvin": {{ kelvin }}{% endif %}}

    - alias: Light set brightness once
      trigger:
        - platform: time
          at: "07:35:01"
        - platform: time
          at: "22:35:01"
        - platform: time
          at: "00:00:01"
      variables:
        brightness: *brightness
      action:
        service: light.turn_on
        data:
          entity_id: >-
            {% if brightness == 255 %}
              {{ expand(states.light) | selectattr("state", "eq", "on") | map(attribute="entity_id") | list }}
            {% else %}
              {{ expand(states.light) | selectattr("state", "eq", "on") | selectattr("attributes.brightness", "gt", brightness) | map(attribute="entity_id") | list }}
            {% endif %}
          brightness: "{{ brightness }}"

    - alias: Light sync kitchen off state
      trigger:
        - platform: state
          entity_id:
            - light.kitchen_door
            - light.kitchen_window
          to: "off"
          for: "00:00:01"
      condition:
        condition: state
        entity_id: light.kitchen
        state: "on"
      action:
        service: light.turn_off
        data:
          entity_id: light.kitchen

    - alias: Light fan light on when dining room light on
      trigger:
        - platform: state
          entity_id: light.16609ab46d42b000_group
          to: "on"
      action:
        - service: homeassistant.update_entity
          data:
            entity_id: light.yeelink_fancl5_e358_light
        - service: light.turn_on
          data:
            entity_id: light.yeelink_fancl5_e358_light

    - alias: Light min brightness when epson projector on
      trigger:
        - platform: state
          entity_id: device_tracker.epson_projector
          to: "home"
      condition:
        - condition: state
          entity_id: light.primary_bedroom
          state: "on"
      action:
        - service: light.turn_on
          data:
            entity_id: light.primary_bedroom
            brightness: 3
  '';
}
