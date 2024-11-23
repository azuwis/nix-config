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
    xiaomi_miot = mkEnableOption "xiaomi_miot";
  };

  config = mkIf (cfg.enable && cfg.xiaomi_miot) {
    services.home-assistant.customComponents = [ pkgs.xiaomi_miot ];

    # `dependencies` and `after_dependencies` in manifest.json
    services.home-assistant.extraComponents = [
      "ffmpeg"
      "homekit"
    ];

    services.home-assistant.config = {
      logger.logs."custom_components.xiaomi_miot" = "critical";
    };

    hass.automations = ''
      - alias: Climate set fan speed
        trigger:
          platform: state
          entity_id:
            # - climate.xiaomi_mt0_6e25_air_conditioner
            # - climate.xiaomi_mt0_bedd_air_conditioner
            - climate.xiaomi_mt0_cdd0_air_conditioner
          from: "off"
          to:
            - cool
            - heat
        action:
          service: fan.set_percentage
          data:
            entity_id: >-
              {{ trigger.entity_id | regex_replace(find='^climate', replace='fan') | regex_replace(find='air_conditioner$', replace='air_fresh') }}
            percentage: 16

      - alias: Climate close all at morning workdays
        trigger:
          - platform: time
            at: "08:30:00"
        condition:
          condition: state
          entity_id: binary_sensor.workday_sensor
          state: "on"
        action:
          - service: climate.turn_off
            data:
              entity_id: >-
                {{ expand(states.climate) | selectattr('entity_id', 'search', '^climate\.xiaomi_mt0_.*_air_conditioner$') | map(attribute='entity_id') | list }}

      - alias: Climate close all at morning holidays
        trigger:
          - platform: time
            at: "09:00:00"
        condition:
          condition: state
          entity_id: binary_sensor.workday_sensor
          state: "off"
        action:
          - service: climate.turn_off
            data:
              entity_id: >-
                {{ expand(states.climate) | selectattr('entity_id', 'search', '^climate\.xiaomi_mt0_.*_air_conditioner$') | map(attribute='entity_id') | list }}

      - alias: Curtain close all before sunrise
        trigger:
          - platform: sun
            event: sunrise
            offset: "-00:45:00"
        action:
          service: cover.close_cover
          data:
            entity_id: all

      - alias: Curtain kids room half close
        trigger:
          - platform: time
            at: "21:30:00"
        action:
          service: cover.set_cover_position
          data:
            entity_id: cover.lumi_hmcn01_ea01_curtain
            position: 35

      - alias: Curtain kids room open workdays
        trigger:
          - platform: time
            at: "07:45:00"
        condition:
          condition: state
          entity_id: binary_sensor.workday_sensor
          state: "on"
        action:
          service: cover.set_cover_position
          data:
            entity_id: cover.lumi_hmcn01_ea01_curtain
            position: 100

      - alias: Curtain kids room open holidays
        trigger:
          - platform: time
            at: "08:45:00"
        condition:
          condition: state
          entity_id: binary_sensor.workday_sensor
          state: "off"
        action:
          service: cover.set_cover_position
          data:
            entity_id: cover.lumi_hmcn01_ea01_curtain
            position: 100

      - alias: Screen brightness
        trigger:
          - platform: time
            at:
              - "08:30:00"
              - "21:30:00"
        action:
          - variables:
              is_night: >-
                {{ (now() > today_at("21:00")) }}
          - service: number.set_value
            data:
              entity_id: >-
                {{ expand(states.number) | selectattr('entity_id', 'search', '^number\.leshow_jsq1_.*_screen_brightness$') | map(attribute='entity_id') | list }}
              value: >-
                {{ is_night | iif(0, 1) }}
          - service: light.turn_{{ is_night | iif("off", "on") }}
            data:
              entity_id: >-
                {{ expand(states.light) | selectattr('entity_id', 'search', '^light.xiaomi_mt0_.*_indicator_light$') | map(attribute='entity_id') | list }}

      - alias: Bath heater auto off
        trigger:
          platform: state
          entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
          to:
            - heat
            - ventilate
          for: "00:30:00"
        action:
          - service: climate.turn_off
            data:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater

      - alias: Fan dining room off when fan light dining room off
        trigger:
          - platform: state
            entity_id: light.yeelink_fancl5_e358_light
            to: "off"
        action:
          - service: fan.turn_off
            data:
              entity_id: fan.yeelink_fancl5_e358_fan

      - alias: Enable ventilate auto when door close
        trigger:
          platform: state
          entity_id: binary_sensor.0x00158d00028f9af8_contact
          to: "off"
          for: "00:02:00"
        action:
          - service: automation.turn_on
            data:
              entity_id: automation.ventilate

      - alias: Enable ventilate auto when approach
        trigger:
          platform: state
          entity_id: sensor.dced8387eef4_action
          attribute: action
          to: "approach"
          for: "00:05:00"
        action:
          - service: automation.turn_on
            data:
              entity_id: automation.ventilate

      - alias: Ventilate
        trigger:
          platform: state
          entity_id: binary_sensor.dced8387eef4_occupancy
          from: "on"
          to: "off"
        action:
          - service: climate.set_preset_mode
            data:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
              preset_mode: Ventilate
          - service: automation.turn_off
            data:
              entity_id: automation.ventilate
    '';
  };
}
