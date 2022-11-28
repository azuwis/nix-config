{ config, lib, pkgs, ... }:

let
 inherit (config.my) domain;
in

{
  security.acme = {
    acceptTerms = true;
    defaults = {
      inherit (config.my) email;
      # DYNU_API_KEY=
      credentialsFile = /etc/secrets/acme;
    };
    certs = {
      default = {
        group = "nginx";
        dnsProvider = "dynu";
        inherit domain;
        extraDomainNames = [
          "*.${domain}"
        ];
        dnsPropagationCheck = false;
        reloadServices = [ "nginx" ];
      };
    };
  };

  services.nginx= {
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
  networking.firewall.allowedTCPPorts = [ 443 ];
}
