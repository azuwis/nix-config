{ config, lib, pkgs, ... }:

{
  services.home-assistant.config = {
    logger.logs."homeassistant.components.yeelight" = "critical";
    yeelight.devices = {
      "yeelink-light-ceiling12_mibtEA04.lan" = {
        name = "Living room";
        model = "ceiling13";
      };
      "yeelink-light-ceiling13_mibtF035.lan" = {
        name = "Primary bedroom";
        model = "ceiling13";
      };
      "yeelink-light-ceiling14_mibtE345.lan" = {
        name = "Secondary bedroom";
        model = "ceiling13";
      };
      "yeelink-light-ceiling13_mibt8675.lan" = {
        name = "Kids room";
        model = "ceiling13";
      };
      "yeelink-light-panel1_mibt8793.lan" = {
        name = "Kitchen door";
        model = "mono1";
      };
      "yeelink-light-panel1_mibt813A.lan" = {
        name = "Kitchen window";
        model = "mono1";
      };
      "yeelink-light-panel1_mibt8400.lan" = {
        name = "Bathroom";
        model = "mono1";
      };
    };
    light = [{
      platform = "group";
      name = "Kitchen";
      entities = [
        "light.kitchen_door"
        "light.kitchen_window"
      ];
    }];
  };
}
