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
    zigbee2mqtt-networkmap = mkEnableOption "hass" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.zigbee2mqtt-networkmap) {
    services.home-assistant.config.mqtt.sensor = [
      {
        name = "Zigbee2mqtt Networkmap";
        state_topic = "zigbee2mqtt/bridge/response/networkmap";
        value_template = ''{{ now().strftime("%Y-%m-%d %H:%M:%S") }}'';
        json_attributes_topic = "zigbee2mqtt/bridge/response/networkmap";
        json_attributes_template = "{{ value_json.data.value | tojson }}";
      }
    ];

    services.home-assistant.customLovelaceModules = [
      pkgs.home-assistant-custom-lovelace-modules.zigbee2mqtt-networkmap
    ];
  };
}
