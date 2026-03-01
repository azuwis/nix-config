{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hass;
in

{
  options.hass = {
    enable = lib.mkEnableOption "hass";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [
      "rpcd"
      "uhttpd"
      "uhttpd-mod-ubus"
    ];
    files.file."usr/share/rpcd/acl.d/hass.json".text = ''
      {
        "hass": {
          "description": "Hass user access role",
          "read": {
            "ubus": {
              "hostapd.*": [ "get_clients" ]
            }
          }
        }
      }
    '';
    uci = {
      # https://github.com/openwrt/openwrt/blob/main/package/system/rpcd/files/rpcd.config
      rpcd."@login[0]".".type" = "-";
      rpcd.hass = {
        ".type" = "login";
        username = "hass";
        read = [
          "hass"
          "unauthenticated"
        ];
      };
      uhttpd.main.redirect_https = "0";
    };
  };
}
