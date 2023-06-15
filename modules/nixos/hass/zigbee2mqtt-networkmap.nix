import ./lovelace-resource.nix {
  url = "https://github.com/azuwis/zigbee2mqtt-networkmap/releases/download/v0.7.0/zigbee2mqtt-networkmap.js";
  sha256 = "sha256-OB2MOzFtSwzmW1b1wxBrWvW2GXdzf80vD/p+t5TN2jE=";
  cfg = {
    services.home-assistant.config.mqtt.sensor = [{
      name = "Zigbee2mqtt Networkmap";
      state_topic = "zigbee2mqtt/bridge/response/networkmap";
      value_template = ''{{ now().strftime("%Y-%m-%d %H:%M:%S") }}'';
      json_attributes_topic = "zigbee2mqtt/bridge/response/networkmap";
      json_attributes_template = "{{ value_json.data.value | tojson }}";
    }];
  };
}
