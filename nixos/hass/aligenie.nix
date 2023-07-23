{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "azuwis";
    repo = "aligenie";
    rev = "cf10771673e916d3e2a0d5a195bd5529731aa558";
    sha256 = "1zxjzb0h2mdcfm78zja5ax2v92g4kqf7afqk3jnh9hj8v4gv8vlp";
  };
in
{
  options.my.hass = {
    aligenie = mkEnableOption (mdDoc "aligenie") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.aligenie) {
    hass.file."custom_components/aligenie".source = "${component}/custom_components/aligenie";

    services.home-assistant.config = {
      aligenie.expire_hours = 9999999;
      homeassistant.customize = {
        "cover.lumi_hmcn01_7c8c_curtain" = {
          hagenie_deviceName = "窗帘";
          hagenie_deviceType = "curtain";
          hagenie_zone = "主卧";
        };
        "cover.lumi_hmcn01_ea01_curtain" = {
          hagenie_deviceName = "窗帘";
          hagenie_deviceType = "curtain";
          hagenie_zone = "儿童房";
        };
        "climate.xiaomi_mt0_bedd_air_conditioner" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "主卧";
        };
        "sensor.xiaomi_mt0_bedd_temperature" = {
          hagenie_deviceName = "温度";
          hagenie_deviceType = "sensor";
          hagenie_zone = "主卧";
        };
        "sensor.xiaomi_mt0_bedd_relative_humidity" = {
          hagenie_deviceName = "湿度";
          hagenie_deviceType = "sensor";
          hagenie_zone = "主卧";
        };
        "climate.xiaomi_mt0_cdd0_air_conditioner" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "次卧";
        };
        "sensor.xiaomi_mt0_cdd0_temperature" = {
          hagenie_deviceName = "温度";
          hagenie_deviceType = "sensor";
          hagenie_zone = "次卧";
        };
        "sensor.xiaomi_mt0_cdd0_relative_humidity" = {
          hagenie_deviceName = "湿度";
          hagenie_deviceType = "sensor";
          hagenie_zone = "次卧";
        };
        "climate.xiaomi_mt0_6e25_air_conditioner" = {
          hagenie_deviceName = "空调";
          hagenie_deviceType = "aircondition";
          hagenie_zone = "儿童房";
        };
        "sensor.xiaomi_mt0_6e25_temperature" = {
          hagenie_deviceName = "温度";
          hagenie_deviceType = "sensor";
          hagenie_zone = "儿童房";
        };
        "sensor.xiaomi_mt0_6e25_relative_humidity" = {
          hagenie_deviceName = "湿度";
          hagenie_deviceType = "sensor";
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
