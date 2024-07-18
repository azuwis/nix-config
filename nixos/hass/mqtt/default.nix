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
    mqtt = mkEnableOption "mqtt";
  };

  config = mkIf (cfg.enable && cfg.mqtt) {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          address = "127.0.0.1";
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    services.home-assistant.config.mqtt = { };
    # services.home-assistant.config.logger.logs."homeassistant.components.mqtt" = "debug";
  };
}
