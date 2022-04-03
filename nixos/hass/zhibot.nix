{ config, lib, pkgs, ... }:

let
  inherit (config.my) domain;
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "Yonsm";
    repo = "ZhiBot";
    rev = "91a4974a104f787c45c81ea4211619afa4235014";
    sha256 = "10iys3g3217vnqgjmhz3d61ls4dsnzbg152sxmmdgd0p919wf7ld";
  };
in

{
  services.home-assistant.config = {
    zhibot = [{
      platform = "genie";
    }];
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
    logger.logs."custom_components.zhibot" = "debug";
  };

  systemd.tmpfiles.rules = [
    "L+ ${config.services.home-assistant.configDir}/custom_components/zhibot - - - - ${component}/custom_components/zhibot"
  ];

  services.nginx.virtualHosts.zhibot = {
    serverName = "i.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    # locations."/" = {
    locations."= /geniebot" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };
}
