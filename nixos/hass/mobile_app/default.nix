{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hass;
in

{
  options.services.hass = {
    mobile_app = lib.mkEnableOption "mobile_app";
  };

  config = lib.mkIf (cfg.enable && cfg.mobile_app) {
    services.home-assistant.config.mobile_app = { };
    hass.automations = ''
      - alias: Run action from notification
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
              msg_parts: >-
                {{ state_attr(trigger.entity_id, "android.text").split(" ") }}
          - action: "{{ msg_parts[1] }}"
            target:
              entity_id: "{{ msg_parts[2] }}"
    '';
  };
}
