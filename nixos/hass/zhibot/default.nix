{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.my) domain;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    zhibot = mkEnableOption "zhibot";
  };

  config = mkIf (cfg.enable && cfg.zhibot) {
    services.home-assistant.customComponents = [ pkgs.zhibot ];

    services.home-assistant.config = {
      zhibot = [
        { platform = "genie"; }
        {
          platform = "genie2";
          token = "!secret zhibot_token";
          file = "!secret zhibot_file";
          text = "!secret zhibot_text";
        }
      ];
      homeassistant.customize = {
        "cover.lumi_hmcn01_7c8c_motor_control" = {
          friendly_name = "主卧窗帘";
        };
        "cover.lumi_hmcn01_ea01_motor_control" = {
          friendly_name = "儿童房窗帘";
        };
        "climate.xiaomi_mt0_bedd_air_conditioner" = {
          friendly_name = "主卧空调";
        };
        "climate.xiaomi_mt0_cdd0_air_conditioner" = {
          friendly_name = "次卧空调";
        };
        "climate.xiaomi_mt0_6e25_air_conditioner" = {
          friendly_name = "儿童房空调";
        };
        "humidifier.leshow_jsq1_4d84_humidifier" = {
          friendly_name = "主卧加湿器";
        };
        "light.living_room" = {
          friendly_name = "客厅灯";
        };
        "light.primary_bedroom" = {
          friendly_name = "主卧灯";
        };
        "light.secondary_bedroom" = {
          friendly_name = "次卧灯";
        };
        "light.kids_room" = {
          friendly_name = "儿童房灯";
        };
        "light.kitchen" = {
          friendly_name = "厨房灯";
        };
        "light.bathroom" = {
          friendly_name = "浴室灯";
        };
        "media_player.sony_kdl_55w800b" = {
          friendly_name = "电视";
        };
      };
      logger.logs."custom_components.zhibot" = "debug";
    };

    services.nginx.virtualHosts.zhibot = {
      serverName = "i.${domain}";
      onlySSL = true;
      useACMEHost = "default";
      # locations."/" = {
      locations."= /geniebot" = {
        proxyPass = "http://127.0.0.1:8123";
      };
      locations."~ ^/(aligenie/|genie2bot$)" = {
        proxyPass = "http://127.0.0.1:8123";
      };
    };
  };
}
