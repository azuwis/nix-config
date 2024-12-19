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
    zigbee2mqtt = mkEnableOption "zigbee2mqtt";
  };

  config = mkIf (cfg.enable && cfg.zigbee2mqtt) {
    # https://github.com/Koenkk/Z-Stack-firmware/tree/master/coordinator/Z-Stack_Home_1.2/bin/default
    # https://github.com/zigpy/zigpy-znp/blob/dev/TOOLS.md
    # nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages(ps: [ps.zigpy-znp])'
    # python3 -m zigpy_znp.tools.nvram_read -o nvram_backup.json /dev/ttyACM0
    # python3 -m zigpy_znp.tools.network_backup -o network_backup.json /dev/ttyACM0
    # python3 -m zigpy_znp.tools.flash_read -o firmware_backup.bin /dev/ttyACM0
    # python3 -m zigpy_znp.tools.flash_write -i CC2531ZNP-Prod.bin /dev/ttyACM0

    my.hass.mqtt = true;

    systemd.services.home-assistant.preStart = ''
      mkdir ${config.services.home-assistant.configDir}/packages
      ln -fns ${./zigbee2mqtt.yaml} ${config.services.home-assistant.configDir}/packages/zigbee2mqtt.yaml
    '';

    services.home-assistant.lovelaceConfig.views = [
      {
        title = "Settings";
        path = "settings";
        icon = "mdi:cog";
        cards = [
          {
            type = "entities";
            show_header_toggle = false;
            entities = [
              { entity = "sensor.zigbee2mqtt_bridge_state"; }
              { entity = "sensor.zigbee2mqtt_version"; }
              { entity = "sensor.zigbee2mqtt_coordinator_version"; }
              { entity = "input_select.zigbee2mqtt_log_level"; }
              { type = "divider"; }
              { entity = "switch.zigbee2mqtt_main_join"; }
              { entity = "input_number.zigbee2mqtt_join_minutes"; }
              { entity = "timer.zigbee_permit_join"; }
            ];
          }
        ];
      }
    ];

    # let my.user read data dir
    systemd.services.zigbee2mqtt.serviceConfig.UMask = lib.mkForce "0027";
    users.users.${config.my.user}.extraGroups = [
      "dialout"
      "zigbee2mqtt"
    ];
    users.users.zigbee2mqtt.homeMode = "0750";

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        advanced = {
          channel = 26;
          last_seen = "ISO_8601_local";
          legacy_availability_payload = false;
          log_output = [ "console" ];
          timestamp_format = " ";
        };
        availability = true;
        device_options = {
          humidity_precision = 1;
          # no_occupancy_since = [ 10 600 ];
          occupancy_timeout = 6;
          temperature_precision = 1;
        };
        devices = {
          # "0x00158d00023d57a9" = { "friendly_name" = "button_a"; };
          # "0x00158d0001e85323" = { "friendly_name" = "button_b"; };
          # "0x00158d0002b88f11" = { "friendly_name" = "button_c"; };
          "0x00158d00027a84d7" = {
            "friendly_name" = "cube";
          };
          # "0x00158d00028f9af8" = { "friendly_name" = "door_bedroom"; };
          "0x00158d0001e81c40" = {
            "friendly_name" = "ht_bedroom";
            "debounce" = 1;
          };
          "0x00158d000215c127" = {
            "friendly_name" = "ht_climate_bedroom";
            "debounce" = 1;
          };
          "0x00158d00022b8fdf" = {
            "friendly_name" = "motion_bathroom";
          };
          "0x00158d00020dfcd8" = {
            "friendly_name" = "motion_kitchen";
          };
          "0x00158d00024689f1" = {
            "friendly_name" = "plug";
          };
          "0x00158d000287aa4d" = {
            "friendly_name" = "smoke";
          };
        };
        frontend = {
          host = "127.0.0.1";
          port = 8083;
        };
        mqtt.server = "mqtt://127.0.0.1:1883";
        serial.disable_led = true;
      };
    };

    services.nginx.virtualHosts.zigbee2mqtt = {
      serverName = "z.${config.my.domain}";
      onlySSL = true;
      useACMEHost = "default";
      extraConfig = ''
        ssl_client_certificate ${config.my.ca};
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
  };
}
