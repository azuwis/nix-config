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
  # OpenWRT: /etc/config/dhcp
  # config dnsmasq
  #   list address '/dis.gree.com/<ip_of_hass>'
  options.my.hass = {
    gree2 = mkEnableOption "gree2" // {
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.gree2) {
    services.home-assistant.customComponents = [ pkgs.gree2 ];

    services.home-assistant.config = {
      climate = [
        {
          platform = "gree2";
          host = "192.168.2.228";
          scan_interval = 20;
          fake_server = "0.0.0.0";
          temp_step = 0.5;
          temp_sensor."9424b8123fe900" = "sensor.1775bcf17c0e_temperature";
        }
      ];

      homeassistant.customize."climate.gree_climate_9424b8123fe900" = {
        friendly_name = "客厅空调";
      };

      # logger.logs."custom_components.gree2" = "debug";
      # logger.logs."custom_components.gree2.climate" = "debug";
    };

    networking.firewall.allowedTCPPorts = [ 1812 ];

    hass.automations = ''
      - alias: Climate living room off when light living room off
        trigger:
          - platform: state
            entity_id: light.living_room
            from: "on"
            to: "off"
        condition:
          - condition: sun
            after: sunset
            before: sunrise
        action:
          - service: climate.turn_off
            data:
              entity_id: climate.gree_climate_9424b8123fe900
    '';
  };
}
