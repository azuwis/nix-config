{ config, lib, pkgs, ... }:

let
  inherit (config.my) domain;
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "raychow";
    repo = "aligenie";
    rev = "2965ac0ca03fe196a67d7214971b26c664eda080";
    sha256 = "sha256-I+E1rH4VFSfUaTmeDYGwFGtgdSTCOp3AxcFv5rHXIwU=";
  };
in

{
  home-manager.users.hass.home.file."custom_components/aligenie".source = "${component}/custom_components/aligenie";

  services.home-assistant.config = {
    aligenie.expire_hours = 9999999;
    homeassistant.customize = {
      "light.living_room" = {
        hagenie_deviceName = "灯";
        hagenie_deviceType = "light";
        hagenie_zone = "客厅";
      };
      "media_player.tv" = {
        hagenie_deviceName = "电视";
        hagenie_deviceType = "television";
        hagenie_zone = "客厅";
      };
      "switch.water_heater" = {
        hagenie_deviceName = "热水器";
        hagenie_deviceType = "waterheater";
        hagenie_zone = "客厅";
      };
      "light.bedroom" = {
        hagenie_deviceName = "灯";
        hagenie_deviceType = "light";
        hagenie_zone = "卧室";
      };
      "climate.bedroom" = {
        hagenie_deviceName = "空调";
        hagenie_deviceType = "aircondition";
        hagenie_zone = "卧室";
      };
      "sensor.ht_bedroom_temperature" = {
        hagenie_deviceName = "温度";
        hagenie_deviceType = "sensor";
        hagenie_zone = "卧室";
      };
      "sensor.ht_bedroom_humidity" = {
        hagenie_deviceName = "湿度";
        hagenie_deviceType = "sensor";
        hagenie_zone = "卧室";
      };
      "light.kitchen" = {
        hagenie_deviceName = "灯";
        hagenie_deviceType = "light";
        hagenie_zone = "厨房";
      };
    };
    logger.logs."custom_components.aligenie" = "debug";
  };

  services.nginx.virtualHosts.aligenie = {
    serverName = "i.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    # locations."/" = {
    locations."= /ali_genie_gate" = {
      proxyPass = "http://127.0.0.1:8123";
    };
  };
}
