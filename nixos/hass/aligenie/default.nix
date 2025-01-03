{
  config,
  lib,
  pkgs,
  ...
}:

# https://iap.aligenie.com/home

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    aligenie = mkEnableOption "aligenie";
  };

  config = mkIf (cfg.enable && cfg.aligenie) {
    services.home-assistant.customComponents = [ pkgs.aligenie ];

    services.home-assistant.config = {
      aligenie.expire_hours = 9999999;
      homeassistant.customize = {
        "cover.lumi_hmcn01_7c8c_motor_control" = {
          hagenie_deviceName = "窗帘";
          hagenie_deviceType = "curtain";
          hagenie_zone = "主卧";
        };
        "cover.lumi_hmcn01_ea01_motor_control" = {
          hagenie_deviceName = "窗帘";
          hagenie_deviceType = "curtain";
          hagenie_zone = "儿童房";
        };
        "climate.xiaomi_mt0_bedd_air_conditioner" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "主卧";
        };
        "climate.xiaomi_mt0_cdd0_air_conditioner" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "次卧";
        };
        "climate.xiaomi_mt0_6e25_air_conditioner" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "儿童房";
        };
        "humidifier.leshow_jsq1_4d84_humidifier" = {
          hagenie_deviceName = "加湿器";
          hagenie_deviceType = "humidifier";
          hagenie_zone = "主卧";
        };
        "climate.gree_climate_9424b8123fe900" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "客厅";
        };
        "light.living_room" = {
          hagenie_deviceName = "灯";
          hagenie_deviceType = "light";
          hagenie_zone = "客厅";
        };
        "light.primary_bedroom" = {
          hagenie_deviceName = "灯";
          hagenie_deviceType = "light";
          hagenie_zone = "主卧";
        };
        "light.secondary_bedroom" = {
          hagenie_deviceName = "灯";
          hagenie_deviceType = "light";
          hagenie_zone = "次卧";
        };
        "light.kids_room" = {
          hagenie_deviceName = "灯";
          hagenie_deviceType = "light";
          hagenie_zone = "儿童房";
        };
        "light.kitchen" = {
          hagenie_deviceName = "灯";
          hagenie_deviceType = "light";
          hagenie_zone = "厨房";
        };
        "light.bathroom" = {
          hagenie_deviceName = "灯";
          hagenie_deviceType = "light";
          hagenie_zone = "浴室";
        };
        "media_player.sony_kdl_55w800b" = {
          hagenie_deviceName = "电视";
          hagenie_deviceType = "television";
          hagenie_zone = "客厅";
        };
      };
      logger.logs."custom_components.aligenie" = "debug";
    };

    services.nginx.virtualHosts.aligenie = {
      serverName = "i.${config.my.domain}";
      onlySSL = true;
      useACMEHost = "default";
      # locations."/" = {
      locations."= /ali_genie_gate" = {
        proxyPass = "http://127.0.0.1:8123";
      };
    };
  };
}
