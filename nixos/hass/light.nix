{ config, lib, pkgs, ... }:

{
  services.home-assistant.config = {
    logger.logs."homeassistant.components.yeelight" = "critical";
    yeelight.devices = {
      "light_living_room.lan" = {
        name = "Living room";
        model = "ceiling4";
        transition = 1000;
      };
      "light_bedroom.lan" = {
        name = "Bedroom";
        model = "ceiling3";
        transition = 1000;
      };
      "light_kitchen.lan" = {
        name = "Kitchen";
        model = "mono1";
        transition = 1000;
      };
    };
  };
}
