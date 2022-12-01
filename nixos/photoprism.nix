{ config, lib, pkgs, ... }:

{
  users.users.${config.my.user}.extraGroups = [ "photoprism" ];

  services.photoprism = {
    enable = true;
    config = {
      DisableTensorFlow = true;
      Experimental = true;
      HttpHost = "127.0.0.1";
      JpegQuality = 92;
      OriginalsLimit = 10000;
      ImportPath = "/srv/photos/import";
      OriginalsPath = "/srv/photos/originals";
    };
  };

  services.nginx.virtualHosts.photoprism = {
    serverName = "p.${config.my.domain}";
    onlySSL = true;
    useACMEHost = "default";
    extraConfig = ''
      ssl_client_certificate ${./ca.crt};
      ssl_verify_client on;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:2342";
      proxyWebsockets = true;
    };
  };
}
