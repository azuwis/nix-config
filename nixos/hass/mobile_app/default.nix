{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hass;
in

# Settings -> Companion app -> Manage Sensors -> Last Notification -> Enable -> Allow List -> Add <apps>
{
  options.services.hass = {
    mobile_app = lib.mkEnableOption "mobile_app";
  };

  config = lib.mkIf (cfg.enable && cfg.mobile_app) {
    services.home-assistant.config.mobile_app = { };
    hass.automations = ''
      - alias: Mobile App run action from notification
        triggers:
          - trigger: state
            entity_id: sensor.az_last_notification
        conditions:
          - condition: template
            value_template: >-
              {{ state_attr(trigger.entity_id, "package") == "com.huawei.smarthome" and
                 state_attr(trigger.entity_id, "android.title").endswith("-推送消息") and
                 state_attr(trigger.entity_id, "android.text").startswith("HASS ") }}
        action:
          - variables:
              parts: >-
                {{ state_attr(trigger.entity_id, "android.text").split(" ") }}
              action: "{{ parts[1] }}"
              entity_id: >-
                {{ parts[2].split(",") }}
              data: >-
                {% set json_str = parts[3:] | join(" ") %}
                {{ json_str | from_json if json_str | length > 0 else {} }}
          - action: "{{ action }}"
            target:
              entity_id: "{{ entity_id }}"
            data: "{{ data }}"
    '';
  };
}
