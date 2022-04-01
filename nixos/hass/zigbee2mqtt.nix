{ config, lib, pkgs, ... }:

let
 inherit (config.my) domain;
in

{
  # https://github.com/Koenkk/Z-Stack-firmware/tree/master/coordinator/Z-Stack_Home_1.2/bin/default
  # https://github.com/zigpy/zigpy-znp/blob/dev/TOOLS.md
  # nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages(ps: [ps.zigpy-znp])'
  # python3 -m zigpy_znp.tools.nvram_read -o nvram_backup.json /dev/ttyACM0
  # python3 -m zigpy_znp.tools.network_backup -o network_backup.json /dev/ttyACM0
  # python3 -m zigpy_znp.tools.flash_read -o firmware_backup.bin /dev/ttyACM0
  # python3 -m zigpy_znp.tools.flash_write -i CC2531ZNP-Prod.bin /dev/ttyACM0
  users.users.${config.my.user}.extraGroups = [ "dialout" ];
  services.zigbee2mqtt = {
    enable = true;
    settings = {
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
      frontend = {
        host = "127.0.0.1";
        port = 8083;
      };
      serial.disable_led = true;
    };
  };

  services.nginx.virtualHosts.zigbee2mqtt = {
    serverName = "z.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    extraConfig = ''
      ssl_client_certificate ${../ca.crt};
      ssl_verify_client on;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:8083";
    };
    locations."/api" = {
      proxyPass = "http://127.0.0.1:8083/api";
      proxyWebsockets = true;
    };
  };

  systemd.tmpfiles.rules = [
    "L+ ${config.services.home-assistant.configDir}/packages/zigbee2mqtt.yaml - - - - ${./zigbee2mqtt.yaml}"
  ];
}
