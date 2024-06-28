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

    hass.automations = '''';
  };
}
