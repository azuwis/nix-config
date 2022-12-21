{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "c419d1f47117ae060aa4959d67da2966e4e225bf";
    sha256 = "sha256-4xYseqe6sNItZmukrBPro2iCZmFJXP7B/XgYswYxdTs=";
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
    - alias: JSQ1 screen brightness
      trigger:
        - platform: time
          at:
            - "08:30"
            - "21:30"
      action:
        service: number.set_value
        data_template:
          entity_id: >-
            {{ expand(states.number) | selectattr('entity_id', 'search', '^number\.leshow_jsq1_.*_screen_brightness$') | map(attribute='entity_id') | list }}
          value: >-
            {{ (now() > today_at("21:00")) | iif(0, 1) }}
  '';
}
