{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nginx;
in

{
  options.services.nginx = {
    enhance = lib.mkEnableOption "nginx";
    openFirewall = lib.mkEnableOption "openFirewall" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enhance {
    security.acme.enhance = true;

    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts.default = {
        default = true;
        onlySSL = true;
        useACMEHost = "default";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 443 ];
  };
}
