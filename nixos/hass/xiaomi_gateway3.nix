{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "AlexxIT";
    repo = "XiaomiGateway3";
    rev = "27f22a5d5e27117120e62eee17c291af53f3afda";
    sha256 = "0jivdk28c43ydkjlmblliypnhkmvd8qzg9jnd6v391gnp1r16900";
  };
in
{
  options.my.hass = {
    xiaomi_gateway3 = mkEnableOption (mdDoc "xiaomi_gateway3") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.xiaomi_gateway3) {
    # Host: Mijia_Hub_V2-2531.lan
    # Open telnet command: {"method":"set_ip_info","params":{"ssid":"\"\"","pswd":"1; passwd -d $USER; iptables -I INPUT \\! --src <hass_ip> -m tcp -p tcp --dport 23 -j DROP; telnetd"}}

    hass.file."custom_components/xiaomi_gateway3".source = "${component}/custom_components/xiaomi_gateway3";

    services.home-assistant.extraPackages = ps: with ps; [
      zigpy
    ];

    services.home-assistant.config = {
      homeassistant.customize_glob."light.*_group".icon = "mdi:lightbulb";
      # logger.logs."custom_components.xiaomi_gateway3" = "debug";
    };

    hass.automations = ''
      - alias: XiaomiGateway set iptables
        trigger:
          - platform: homeassistant
            event: start
          - platform: state
            entity_id: binary_sensor.54ef44432531_gateway
            to: "on"
        action:
          service: xiaomi_gateway3.send_command
          data:
            command: miio
            host: Mijia_Hub_V2-2531.lan
            data: >-
              {"method":"set_ip_info","params":{"ssid":"\"\"","pswd":"1; iptables -C INPUT \\! --src nuc -m tcp -p tcp --dport 23 -j DROP || iptables -I INPUT \\! --src nuc -m tcp -p tcp --dport 23 -j DROP"}}

      - alias: Light bathroom on when sensor on
        trigger:
          platform: state
          entity_id: binary_sensor.dced8387eef4_occupancy
          from: "off"
          to: "on"
        condition:
          condition: state
          entity_id: light.bathroom
          state: "off"
        action:
          service: light.turn_on
          data:
            entity_id: light.bathroom

      - alias: Light bathroom off when sensor off
        trigger:
          platform: state
          entity_id: binary_sensor.dced8387eef4_occupancy
          from: "on"
          to: "off"
        condition:
          condition: state
          entity_id: light.bathroom
          state: "on"
        action:
          service: light.turn_off
          data:
            entity_id: light.bathroom

      - alias: Light kitchen on when sensor on
        trigger:
          platform: state
          entity_id: binary_sensor.649e314c943b_occupancy
          from: "off"
          to: "on"
        condition:
          - condition: state
            entity_id: light.kitchen
            state: "off"
          - condition: numeric_state
            entity_id: sensor.649e314c943b_illuminance
            below: 1500
        action:
          service: light.turn_on
          data:
            entity_id: light.kitchen

      - alias: Light kitchen off when sensor off
        trigger:
          platform: state
          entity_id: binary_sensor.649e314c943b_occupancy
          from: "on"
          to: "off"
        condition:
          condition: state
          entity_id: light.kitchen
          state: "on"
        action:
          service: light.turn_off
          data:
            entity_id: light.kitchen
    '';
  };
}
