{ config, lib, pkgs, ... }:

# https://iap.aligenie.com/home

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "azuwis";
    repo = "aligenie";
    rev = "626284b3a3e06d1f616e5d55f76ed58008c235c0";
    sha256 = "1k8g83zn7mxjn7mjbvr2372y89zqzdz3pv3vbzab071mzw8a46a3";
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
        "climate.living_room" = {
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
