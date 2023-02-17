{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "AlexxIT";
    repo = "XiaomiGateway3";
    rev = "7596fc1d6c342fe9ba0e088bcb48aa65f42c31b2";
    sha256 = "0kbgv2m9pzpvgmncxgswn937nrl8dc3zmsprcw89ip756400mvyz";
  };
in

{
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

    - alias: Lights bathroom off when sensor off
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
  '';
}
