{ config, lib, pkgs, ... }:

{
  services.mosquitto = {
    enable = true;
    listeners = [{
      acl = [ "pattern readwrite #" ];
      address = "127.0.0.1";
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    }];
  };

  services.home-assistant.config.mqtt = {};
  # services.home-assistant.config.logger.logs."homeassistant.components.mqtt" = "debug";
}
