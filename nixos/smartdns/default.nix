{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.smartdns;
in

{
  config = lib.mkIf cfg.enable {
    environment.etc."resolv.conf".text = lib.mkForce ''
      nameserver ${builtins.elemAt cfg.settings.bind 0}
    '';

    services.resolved.enable = true;
    # When resolved enabled, /etc/nsswitch.conf will have `hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns`,
    # which will make apps like `ping` `firefox` prefer systemd-resolved, and ignore /etc/resolv.conf.
    # Can not easily remove `resolve [!UNAVAIL=return]`, so override all. Be ware if future NixOS version changes
    # `system.nssDatabases.hosts`, new values should be set.
    system.nssDatabases.hosts = lib.mkForce [ "mymachines files myhostname dns" ];

    services.smartdns.settings = {
      bind = "127.0.0.52";
      cache-size = 4096;
      force-AAAA-SOA = true;
      force-qtype-SOA = 65;
      nameserver = [
        "/detectportal.firefox.com/local"
        "/lan/local"
        "/netease.com/local"
      ];
      prefetch-domain = true;
      rr-ttl-min = 600;
      serve-expired = true;
      server = "127.0.0.54 -group local";
      server-quic = "223.5.5.5";
      server-tls = "1.0.0.1";
      user = "nobody";
    };
  };
}
