{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "ad6693eb627d4bec10635f1b85c565932aa27266";
    sha256 = "13vnn22xsjmybflp3pajqi7zhlgigf190jvhyyq0fz0kr49g9bpv";
  };
in
{
  options.my.hass = {
    xiaomi_miot = mkEnableOption (mdDoc "xiaomi_miot") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.xiaomi_miot) {
    hass.file."custom_components/xiaomi_miot".source = "${component}/custom_components/xiaomi_miot";

    services.home-assistant.extraPackages = ps: with ps; [
      hap-python
      micloud
      pyqrcode
      python-miio
    ];

    services.home-assistant.config = {
      ffmpeg = { };
      logger.logs."custom_components.xiaomi_miot" = "critical";
    };

    hass.automations = ''
      - alias: Climate set fan speed
        trigger:
          platform: state
          entity_id:
            - climate.xiaomi_mt0_6e25_air_conditioner
            - climate.xiaomi_mt0_bedd_air_conditioner
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
            percentage: 34

      - alias: Climate close all at morning
        trigger:
          - platform: time
            at: "08:30:00"
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

      - alias: Curtain kids room autos
        trigger:
          - platform: time
            at:
              - "07:45:00"
              - "21:30:00"
        variables:
          position: >-
            {% if now() > today_at("21:00") %}
              60
            {% else %}
              100
            {% endif %}
        action:
          service: cover.set_cover_position
          data:
            entity_id: cover.lumi_hmcn01_ea01_curtain
            position: "{{ position }}"

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
          from: "off"
          to:
            - ventilate
          for: "01:30:00"
        action:
          - service: climate.turn_off
            data:
              entity_id: climate.yeelink_v6_af1f_ptc_bath_heater
    '';
  };
}
