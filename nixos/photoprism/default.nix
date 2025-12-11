{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.photoprism;
in
{
  options.services.photoprism = {
    enhance = lib.mkEnableOption "photoprism";
  };

  config = lib.mkIf cfg.enhance {
    services.photoprism = {
      enable = true;
      originalsPath = "/srv/photos/originals";
      importPath = "/srv/photos/import";
      settings = {
        PHOTOPRISM_DEFAULT_LOCALE = "zh";
        PHOTOPRISM_DISABLE_PLACES = "true";
        # PHOTOPRISM_DISABLE_TENSORFLOW = "true";
        PHOTOPRISM_EXPERIMENTAL = "true";
        # PHOTOPRISM_JPEG_QUALITY = "92";
        PHOTOPRISM_ORIGINALS_LIMIT = "10000";
      };
    };

    services.nginx.enhance = lib.mkDefault true;
    services.nginx.virtualHosts.photoprism = {
      serverName = "p.${config.my.domain}";
      onlySSL = true;
      useACMEHost = "default";
      extraConfig = ''
        ssl_client_certificate ${config.my.ca};
        ssl_verify_client on;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:2342";
        proxyWebsockets = true;
      };
    };
  };
}
