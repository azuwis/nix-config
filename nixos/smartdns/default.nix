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
