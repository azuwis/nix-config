{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.smartdns;
  domains = ./domains;
  smartdnsConf = pkgs.runCommand "smartdns.conf" {} ''
    pwd
    sed -e 's,^,server=/,' -e 's,$,/${cfg.bind}#${toString cfg.localDomainPort},' ${domains} >$out
  '';
  smartdnsUpdate = pkgs.writeScript "smartdns-update" ''
    #!/bin/sh
    smartdns="${cfg.bind}"
    if ! grep -q '^nameserver ' /var/run/resolv.conf
    then
      networksetup -listallnetworkservices | grep -v '*' | while read -r service
      do
        if [ "$(networksetup -getdnsservers "$service")" = "$smartdns" ]
        then
          networksetup -setdnsservers "$service" Empty
        fi
      done
    else
      iface="$(netstat -rnf inet | awk '/^default/ {print $4}')"
      test -z "$iface" && exit
      dns="$(ipconfig getoption "$iface" domain_name_server)"
      test -z "$dns" && exit
      if ! grep -qFx "nameserver $dns" /var/run/smartdns-update
      then
        echo "nameserver $dns" > /var/run/smartdns-update
      fi
      service="$(networksetup -listnetworkserviceorder | sed -rn "s/.*: ([^,]+),.*$iface\).*/\1/p")"
      test -z "$service" && exit
      if [ "$(networksetup -getdnsservers "$service")" != "$smartdns" ]
      then
        networksetup -setdnsservers "$service" "$smartdns"
      fi
    fi
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
        "--resolv-file=/var/run/smartdns-update"
        "--strict-order"
        "--cache-size=0"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };

    launchd.daemons.smartdns-update = {
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
        "--server=${cfg.remoteDomainServer}"
        "--servers-file=${smartdnsConf}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
