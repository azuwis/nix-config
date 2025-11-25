{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.hass;
in
{
  options.services.hass = {
    acpartner = mkEnableOption "acpartner";
  };

  config = mkIf (cfg.enable && cfg.acpartner) {
    services.home-assistant.customComponents = [ pkgs.xiaomi_miio_airconditioningcompanion ];

    services.home-assistant.config = {
      climate = [
        {
          platform = "xiaomi_miio_airconditioningcompanion";
          name = "AC partner";
          host = "acpartner.lan";
          token = "!secret ac_partner_token";
          target_sensor = "sensor.ht_bedroom_temperature";
        }
      ];
    };
  };
}
