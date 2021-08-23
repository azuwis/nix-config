{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.smartdns;
  domains = ./domains;
  smartdnsConf = pkgs.runCommand "smartdns.conf" {} ''
    pwd
    sed -e 's,^,server=/,' -e 's,$,/${cfg.bind}#${toString cfg.localDomainPort},' ${domains} >$out
  '';
in

{
  options = {
    services.smartdns.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable SmartDNS.";
    };

    services.smartdns.package = mkOption {
      type = types.path;
      default = pkgs.dnsmasq;
      defaultText = "pkgs.dnsmasq";
      description = "The dnsmasq package to use.";
    };

    services.smartdns.bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The interface on which SmartDNS will listen.";
    };

    services.smartdns.port = mkOption {
      type = types.int;
      default = 53;
      description = "The port on which SmartDNS will listen.";
    };

    services.smartdns.localDomainPort = mkOption {
      type = types.int;
      default = 54;
      description = "The port on which SmartDNS will listen for local domains.";
    };

    services.smartdns.remoteDomainServer = mkOption {
      type = types.str;
      default = "127.0.0.1#55";
      description = "The server on which SmartDNS will forward for remote domains.";
    };
  };

  config = mkIf cfg.enable {
    launchd.daemons.smartdns-local = {
      serviceConfig.ProgramArguments = [
        "${cfg.package}/bin/dnsmasq"
        "--keep-in-foreground"
        "--listen-address=${cfg.bind}"
        "--port=${toString cfg.localDomainPort}"
        "--strict-order"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };

    launchd.daemons.smartdns = {
      serviceConfig.ProgramArguments = [
        "${cfg.package}/bin/dnsmasq"
        "--keep-in-foreground"
        "--listen-address=${cfg.bind}"
        "--port=${toString cfg.port}"
        "--no-resolv"
        "--server=${cfg.remoteDomainServer}"
        "--servers-file=${smartdnsConf}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
