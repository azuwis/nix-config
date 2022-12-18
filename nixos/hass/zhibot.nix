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
  home-manager.users.hass.home.file."custom_components/zhibot".source = "${component}/custom_components/zhibot";

  services.home-assistant.config = {
    zhibot = [
      {
        platform = "genie";
      }
      {
        platform = "genie2";
        token = "!secret zhibot_token";
        file = "!secret zhibot_file";
        text = "!secret zhibot_text";
      }
    ];
    homeassistant.customize = {
      "climate.bedroom" = {
        friendly_name = "空调";
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
        friendly_name = "卫生间灯";
      };
      "media_player.tv" = {
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
}
