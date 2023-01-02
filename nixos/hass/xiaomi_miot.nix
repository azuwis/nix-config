{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "375cf4b0d700fc82444c23b110ebfe4f903ada74";
    sha256 = "1ivz0klygpbb5pdlyqcz22hb1l9dzzj0wmc1ygl3nrjb0p9fnmi2";
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
