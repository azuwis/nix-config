{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.smartdns;
  localDomains = ./local-domains;
  smartdnsConf = pkgs.runCommand "smartdns.conf" {} ''
    sed -e 's,^,server=/,' -e 's,$,/${cfg.local.bind}#${toString cfg.local.port},' ${localDomains} >$out
  '';
  smartdnsUpdate = pkgs.substituteAll {
    src = ./smartdns-update.sh;
    isExecutable = true;
    smartdns = cfg.bind;
  };
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

    services.smartdns.local.bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The interface on which SmartDNS will listen for local domains.";
    };

    services.smartdns.local.port = mkOption {
      type = types.int;
      default = 54;
      description = "The port on which SmartDNS will listen for local domains.";
    };

    services.smartdns.remoteServer = mkOption {
      type = types.str;
      default = "127.0.0.1#55";
      description = "The server on which SmartDNS will forward for remote domains.";
    };

    services.smartdns.update.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable SmartDNS auto set DNS server for this computer.";
    };
  };

  config = mkIf cfg.enable {
    launchd.daemons.smartdns-local = {
      serviceConfig.ProgramArguments = [
        "${cfg.package}/bin/dnsmasq"
        "--keep-in-foreground"
        "--listen-address=${cfg.local.bind}"
        "--port=${toString cfg.local.port}"
        "--resolv-file=/var/run/${if cfg.update.enable then "smartdns-update" else "resolv.conf"}"
        "--strict-order"
        "--cache-size=0"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };

    launchd.daemons.smartdns-update = mkIf cfg.update.enable {
      serviceConfig.ProgramArguments = [
        "${smartdnsUpdate}"
      ];
      serviceConfig.RunAtLoad = true;
      serviceConfig.ThrottleInterval = 1;
      serviceConfig.WatchPaths = [
        "/var/run/resolv.conf"
      ];
      # serviceConfig.StandardErrorPath = "/tmp/smartdns.log";
    };

    launchd.daemons.smartdns = {
      serviceConfig.ProgramArguments = [
        "${cfg.package}/bin/dnsmasq"
        "--keep-in-foreground"
        "--listen-address=${cfg.bind}"
        "--port=${toString cfg.port}"
        "--no-resolv"
        "--server=${cfg.remoteServer}"
        "--servers-file=${smartdnsConf}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
