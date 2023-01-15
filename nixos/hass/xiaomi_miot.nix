{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "3705aa8568e47c3b9ca4fe26cf68e960a5dc2f35";
    sha256 = "0w636w44phjvj18jhrc7hvcjvxd4iy27sd1mjd4nksjm3mc04bgw";
  };
in

{
  hass.file."custom_components/xiaomi_miot".source = "${component}/custom_components/xiaomi_miot";

  services.home-assistant.extraPackages = ps: with ps; [
    hap-python
    micloud
    pyqrcode
    python-miio
  ];

  services.home-assistant.config = {
    ffmpeg = {};
    # logger.logs."custom_components.xiaomi_miot" = "debug";
  };

  hass.automations = ''
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
            - "21:30:00"
            - "08:30:00"
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
            - "08:30"
            - "21:30"
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
  '';
}
