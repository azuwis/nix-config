{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.acme;

  inherit (config.my) domain;
in
{
  options.my.acme = {
    enable = mkEnableOption (mdDoc "acme");
  };

  config = mkIf cfg.enable {
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
  };
}
