{ config, lib, pkgs, ... }:

let
  js = pkgs.fetchurl {
    url = "https://github.com/azuwis/zigbee2mqtt-networkmap/releases/download/v0.7.0/zigbee2mqtt-networkmap.js";
    sha256 = "sha256-OB2MOzFtSwzmW1b1wxBrWvW2GXdzf80vD/p+t5TN2jE=";
  };
in

{
  services.nginx.virtualHosts.hass = {
    locations."= /local/zigbee2mqtt-networkmap.js" = {
      alias = js;
    };
  };

  services.home-assistant.config = {
    lovelace.resources = [{
      url = "/local/zigbee2mqtt-networkmap.js?v=${builtins.hashFile "md5" js}";
      type = "module";
    }];
    mqtt.sensor = [{
      name = "Zigbee2mqtt Networkmap";
      state_topic = "zigbee2mqtt/bridge/response/networkmap";
      value_template = ''{{ now().strftime("%Y-%m-%d %H:%M:%S") }}'';
      json_attributes_topic = "zigbee2mqtt/bridge/response/networkmap";
      json_attributes_template = "{{ value_json.data.value | tojson }}";
    }];
  };
}
