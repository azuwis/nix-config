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
      rpcd."@login[0]".username = "hass";
      rpcd."@login[0]".read = [
        "hass"
        "unauthenticated"
      ];
      rpcd."@login[0]".write = [ ];
      uhttpd.main.redirect_https = "0";
    };
  };
}
