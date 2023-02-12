{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "AlexxIT";
    repo = "XiaomiGateway3";
    rev = "9bf168671a3f946c331eeacf1046aee96ccb3084";
    sha256 = "sha256-QwsUmtB+n7Vp779kE0vL++xhmySHuLD1sbczyxa1EHc=";
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
    # logger.logs."custom_components.xiaomi_gateway3" = "debug";
  };

  hass.automations = ''
    - alias: Lights bathroom on when sensor on
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
