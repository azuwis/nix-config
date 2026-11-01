{
  inputs,
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
    age.secrets.acme-dynu.file = "${inputs.my.outPath}/acme-dynu.age";

    security.acme = {
      acceptTerms = true;
      defaults = {
        inherit (config.my) email;
      };
      certs = {
        default = {
          group = "nginx";
          dnsProvider = "dynu";
          inherit domain;
          extraDomainNames = [ "*.${domain}" ];
          dnsPropagationCheck = false;
          credentialFiles.DYNU_API_KEY_FILE = config.age.secrets.acme-dynu.path;
          reloadServices = [ "nginx" ];
        };
      };
    };
  };
}
