{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.scidns;
  localDomains = ./local-domains;
  scidnsConf = pkgs.runCommand "scidns.conf" { } ''
    sed -e 's,^,server=/,' -e 's,$,/${cfg.local.bind}#${toString cfg.local.port},' ${localDomains} >$out
  '';
  scidnsResolvScript = pkgs.substituteAll {
    src = ./scidns-resolv.sh;
    isExecutable = true;
    scidns = cfg.bind;
    launchdLabel = config.launchd.daemons.scidns-resolv.serviceConfig.Label;
  };
in

{
  options = {
    services.scidns.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable SciDNS.";
    };

    services.scidns.package = mkOption {
      type = types.path;
      default = pkgs.dnsmasq;
      defaultText = "pkgs.dnsmasq";
      description = "The dnsmasq package to use.";
    };

    services.scidns.bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The interface on which SciDNS will listen.";
    };

    services.scidns.port = mkOption {
      type = types.int;
      default = 53;
      description = "The port on which SciDNS will listen.";
    };

    services.scidns.local.bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The interface on which SciDNS will listen for local domains.";
    };

    services.scidns.local.port = mkOption {
      type = types.int;
      default = 54;
      description = "The port on which SciDNS will listen for local domains.";
    };

    services.scidns.remoteServer = mkOption {
      type = types.str;
      default = "127.0.0.1#55";
      description = "The server on which SciDNS will forward for remote domains.";
    };

    services.scidns.resolv.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable SciDNS auto set DNS server for this computer.";
    };

    services.scidns.resolv.script = mkOption {
      type = types.path;
      default = scidnsResolvScript;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    launchd.daemons.scidns-local = {
      serviceConfig.ProgramArguments = [
        "/bin/sh"
        "-c"
        ''/bin/wait4path /nix/store && exec "$@"''
        "--"
        "${cfg.package}/bin/dnsmasq"
        "--keep-in-foreground"
        "--listen-address=${cfg.local.bind}"
        "--port=${toString cfg.local.port}"
        "--resolv-file=/var/run/${if cfg.resolv.enable then "scidns-resolv" else "resolv.conf"}"
        "--strict-order"
        "--cache-size=0"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };

    launchd.daemons.scidns-resolv = mkIf cfg.resolv.enable {
      serviceConfig.ProgramArguments = [ "${scidnsResolvScript}" ];
      serviceConfig.ThrottleInterval = 1;
      serviceConfig.WatchPaths = [ "/var/run/resolv.conf" ];
      # serviceConfig.StandardErrorPath = "/tmp/scidns.log";
    };

    launchd.daemons.scidns = {
      serviceConfig.ProgramArguments = [
        "/bin/sh"
        "-c"
        ''/bin/wait4path /nix/store && exec "$@"''
        "--"
        "${cfg.package}/bin/dnsmasq"
        "--keep-in-foreground"
        "--listen-address=${cfg.bind}"
        "--port=${toString cfg.port}"
        "--no-resolv"
        "--server=${cfg.remoteServer}"
        "--servers-file=${scidnsConf}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
