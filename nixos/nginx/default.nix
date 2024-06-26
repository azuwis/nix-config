{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.nginx;

  inherit (config.my) domain;
in
{
  options.my.nginx = {
    enable = mkEnableOption "nginx";
    openFirewall = mkEnableOption "openFirewall" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    my.acme.enable = true;

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

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 443 ];
  };
}
