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
    services.home-assistant.customComponents = [ pkgs.home-assistant-custom-components.xiaomi_miot ];

    # `dependencies` and `after_dependencies` in manifest.json
    services.home-assistant.extraComponents = [
      "ffmpeg"
      "homekit"
    ];

    services.home-assistant.config = {
      logger.logs."custom_components.xiaomi_miot" = "critical";
    };

    hass.automations = ''
      - alias: Climate set fan speed when on
        triggers:
          - trigger: state
            entity_id:
              # - climate.xiaomi_mt0_6e25_air_conditioner
              # - climate.xiaomi_mt0_bedd_air_conditioner
              - climate.xiaomi_mt0_cdd0_air_conditioner
            from: "off"
            to:
              - cool
              - heat
        actions:
          - action: fan.set_percentage
            target:
              entity_id: >-
                {{ trigger.entity_id | regex_replace(find='^climate', replace='fan') | regex_replace(find='air_conditioner$', replace='air_fresh') }}
            data:
              percentage: 16

      - alias: Climate close all at morning workdays
        triggers:
          - trigger: time
            at: "08:30:00"
        conditions:
          - condition: state
            entity_id: binary_sensor.workday_sensor
            state: "on"
        actions:
          - action: climate.turn_off
            target:
              entity_id: >-
                {{ expand(states.climate) | selectattr('entity_id', 'search', '^climate\.xiaomi_mt0_.*_air_conditioner$') | map(attribute='entity_id') | list }}

      - alias: Climate close all at morning holidays
        triggers:
          - trigger: time
            at: "09:00:00"
        conditions:
          - condition: state
            entity_id: binary_sensor.workday_sensor
            state: "off"
        actions:
          - action: climate.turn_off
            target:
              entity_id: >-
                {{ expand(states.climate) | selectattr('entity_id', 'search', '^climate\.xiaomi_mt0_.*_air_conditioner$') | map(attribute='entity_id') | list }}

      - alias: Curtain close all before sunrise
        triggers:
          - trigger: sun
            event: sunrise
            offset: "-00:45:00"
        actions:
          - action: cover.close_cover
            target:
              entity_id: all

      - alias: Curtain kids room half close
        triggers:
          - trigger: time
            at: "21:30:00"
        conditions:
          - condition: numeric_state
            entity_id: cover.lumi_hmcn01_ea01_curtain
            attribute: curtain.current_position
            above: 35
        actions:
          - action: cover.set_cover_position
            target:
              entity_id: cover.lumi_hmcn01_ea01_curtain
            data:
              position: 35

      - alias: Curtain kids room open workdays
        triggers:
          - trigger: time
            at: "07:45:00"
        conditions:
          - condition: state
            entity_id: binary_sensor.workday_sensor
            state: "on"
        actions:
          - action: cover.set_cover_position
            target:
              entity_id: cover.lumi_hmcn01_ea01_curtain
            data:
              position: 100

      - alias: Curtain kids room open holidays
        triggers:
          - trigger: time
            at: "08:45:00"
        conditions:
          - condition: state
            entity_id: binary_sensor.workday_sensor
            state: "off"
        actions:
          - action: cover.set_cover_position
            target:
              entity_id: cover.lumi_hmcn01_ea01_curtain
            data:
              position: 100

      - alias: Curtain primary bedroom half close
        triggers:
          - trigger: time
            at: "23:00:00"
        conditions:
          - condition: numeric_state
            entity_id: cover.lumi_hmcn01_7c8c_curtain
            attribute: curtain.current_position
            above: 20
        actions:
          - action: cover.set_cover_position
            target:
              entity_id: cover.lumi_hmcn01_7c8c_curtain
            data:
              position: 20

      - alias: Screen brightness
        triggers:
          - trigger: time
            at:
              - "08:30:00"
              - "21:30:00"
        actions:
          - variables:
              is_night: >-
                {{ (now() > today_at("21:00")) }}
          - action: number.set_value
            target:
              entity_id: >-
                {{ expand(states.number) | selectattr('entity_id', 'search', '^number\.leshow_jsq1_.*_screen_brightness$') | map(attribute='entity_id') | list }}
            data:
              value: >-
                {{ is_night | iif(0, 1) }}
          - action: light.turn_{{ is_night | iif("off", "on") }}
            target:
              entity_id: >-
                {{ expand(states.light) | selectattr('entity_id', 'search', '^light.xiaomi_mt0_.*_indicator_light$') | map(attribute='entity_id') | list }}

      - alias: Bath heater auto off
        triggers:
          - trigger: state
            entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
            to:
              - heat
              - ventilate
            for: "00:30:00"
        actions:
          - action: climate.turn_off
            target:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater

      - alias: Fan dining room off when fan light dining room off
        triggers:
          - trigger: state
            entity_id: light.yeelink_fancl5_e358_light
            to: "off"
        actions:
          - action: fan.turn_off
            target:
              entity_id: fan.yeelink_fancl5_e358_fan

      - alias: Auto ventilate on when approach or door close
        triggers:
          - trigger: state
            entity_id: sensor.dced8387eef4_action
            attribute: action
            to: "approach"
            for: "00:10:00"
          - trigger: state
            entity_id: binary_sensor.0x00158d00028f9af8_contact
            to: "off"
            for: "00:02:00"
        actions:
          - action: automation.turn_on
            target:
              entity_id: automation.ventilate

      - alias: Ventilate
        triggers:
          - trigger: state
            entity_id: binary_sensor.dced8387eef4_occupancy
            to: "off"
        conditions:
          - condition: state
            entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
            state: "off"
        actions:
          - action: climate.set_preset_mode
            target:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
            data:
              preset_mode: Ventilate
          - action: automation.turn_off
            target:
              entity_id: automation.ventilate

      - alias: Ventilate on at morning
        triggers:
          - trigger: time
            at:
              - "06:50:00"
              - "07:21:00"
        conditions:
          - condition: numeric_state
            entity_id: sensor.xiaomi_mt0_cdd0_co2_density
            above: 800
        actions:
          - action: climate.set_preset_mode
            target:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
            data:
              preset_mode: Ventilate

      - alias: Ventilate off when door close and cold
        triggers:
          - trigger: state
            entity_id: binary_sensor.0x00158d00028f9af8_contact
            to: "off"
        conditions:
          - condition: numeric_state
            entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
            attribute: current_temperature
            below: 23
          - condition: state
            entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
            state: ventilate
        actions:
          - action: climate.turn_off
            target:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
    '';
  };
}
