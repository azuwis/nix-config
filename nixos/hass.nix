{ config, lib, pkgs, ...}:

{
  services.mosquitto = {
    enable = true;
    listeners = [{
      address = "127.0.0.1";
      settings = {
        allow_anonymous = true;
      };
    }];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      serial.disable_led = true;
      advanced = {
        channel = 26;
        last_seen = "ISO_8601_local";
        log_output = [ "console" ];
        timestamp_format = " ";
      };
      availability = true;
      device_options = {
        humidity_precision = 1;
        no_occupancy_since = [ 10 600 ];
        occupancy_timeout = 120;
        temperature_precision = 1;
      };
      devices = {
        "0x00158d00023d57a9" = { "friendly_name" = "button_a"; };
        "0x00158d0001e85323" = { "friendly_name" = "button_b"; };
        "0x00158d0002b88f11" = { "friendly_name" = "button_c"; };
        "0x00158d00027a84d7" = { "friendly_name" = "cube"; };
        "0x00158d00028f9af8" = { "friendly_name" = "door_bedroom"; };
        "0x00158d0001e81c40" = { "friendly_name" = "ht_bedroom"; "debounce" = 1; };
        "0x00158d000215c127" = { "friendly_name" = "ht_climate_bedroom"; "debounce" = 1; };
        "0x00158d00022b8fdf" = { "friendly_name" = "motion_living_room"; };
        "0x00158d00020dfcd8" = { "friendly_name" = "motion_dining_room"; };
        "0x00158d00024689f1" = { "friendly_name" = "plug"; };
        "0x00158d000287aa4d" = { "friendly_name" = "smoke"; };
      };
    };
  };
}
