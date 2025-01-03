{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.my.hass.enable {
    services.home-assistant.config = {
      logger.logs."homeassistant.components.yeelight" = "critical";
      # miiocli cloud
      # miiocli yeelight --ip IP_OF_DEVICE --token TOKEN_OF_DEVICE set_developer_mode 1
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
        "yeelink-light-panel1_mibt98B7.lan" = {
          name = "Bathroom";
        };
      };
      homeassistant.customize =
        let
          customize = {
            supported_color_modes = [ "brightness" ];
          };
        in
        {
          "light.kitchen".icon = "mdi:lightbulb";
          "light.bathroom" = customize;
          "light.kitchen_door" = customize;
          "light.kitchen_window" = customize;
        };
      light = [
        {
          platform = "group";
          name = "Kitchen";
          entities = [
            "light.kitchen_door"
            "light.kitchen_window"
          ];
        }
      ];
    };

    hass.automations = ''
      - alias: Light brightness
        mode: parallel
        triggers:
          - trigger: state
            entity_id:
              - light.living_room
              - light.1660a6874242f000_group
              - light.16609ab46d42b000_group
              - light.1697cc678402b000_group
              - light.yeelink_fancl5_e358_switch_status
              - light.primary_bedroom
              - light.secondary_bedroom
              - light.kids_room
              - light.kitchen_door
              - light.kitchen_window
              - light.bathroom
            from: "off"
            to: "on"
        variables:
          brightness: &brightness >-
            {% set now = now() %}
            {% if now > today_at("22:35") %}
              128
            {% elif now < today_at("7:10") %}
              3
            {% else %}
              255
            {% endif %}
          color_temp: >-
            {{ "color_temp" in state_attr(trigger.entity_id, "supported_color_modes") }}
          kelvin: 5235
        conditions:
          - condition: template
            value_template: >-
              {{ (state_attr(trigger.entity_id, "brightness") != brightness) or
                 (color_temp and (state_attr(trigger.entity_id, "color_temp_kelvin") != kelvin))
              }}
        actions:
          - action: light.turn_on
            target:
              entity_id: "{{ trigger.entity_id }}"
            data: >-
              {"brightness": {{ brightness }}{% if color_temp %}, "kelvin": {{ kelvin }}{% endif %}}

      - alias: Light set brightness once
        triggers:
          - trigger: time
            at:
              - "07:10:01"
              - "22:35:01"
              - "00:00:01"
        variables:
          brightness: *brightness
        actions:
          - action: light.turn_on
            target:
              entity_id: >-
                {% set lights = expand(states.light) | selectattr("state", "eq", "on") %}
                {% if brightness != 255 %}
                  {% set lights = lights | selectattr("attributes.brightness", "defined") | rejectattr("attributes.brightness", "none") | selectattr("attributes.brightness", "gt", brightness) %}
                {% endif %}
                {{ lights | map(attribute="entity_id") | list }}
            data:
              brightness: "{{ brightness }}"

      - alias: Light sync kitchen on state
        triggers:
          - trigger: state
            entity_id:
              - light.kitchen_door
              - light.kitchen_window
            from: "off"
            to: "on"
            for: "00:00:01"
        actions:
          - action: light.turn_on
            target:
              entity_id:
                - light.kitchen_door
                - light.kitchen_window

      - alias: Light fan light on when dining room light on
        triggers:
          - trigger: state
            entity_id: light.16609ab46d42b000_group
            from: "off"
            to: "on"
        actions:
          - action: homeassistant.update_entity
            target:
              entity_id: light.yeelink_fancl5_e358_switch_status
          - action: light.turn_on
            target:
              entity_id: light.yeelink_fancl5_e358_switch_status
    '';
  };
}
