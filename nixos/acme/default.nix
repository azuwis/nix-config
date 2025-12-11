{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.security.acme;

  inherit (config.my) domain;
in
{
  options.security.acme = {
    enhance = mkEnableOption "and enhance acme";
  };

  config = mkIf cfg.enhance {
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
          extraDomainNames = [ "*.${domain}" ];
          dnsPropagationCheck = false;
          reloadServices = [ "nginx" ];
        };
      };
    };
  };
}
