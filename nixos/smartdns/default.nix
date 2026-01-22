{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.services.smartdns;
in

{
  options.services.smartdns = {
    enhance = lib.mkEnableOption "and enhance smartdns";
  };

  # Remove `resolve [!UNAVAIL=return]` (added by `services.resolved.enable`) from /etc/nsswitch.conf, see bellow for details
  # Idea from https://discourse.nixos.org/t/73289/20
  options.system.nssDatabases.hosts = lib.mkOption {
    apply =
      defns:
      if cfg.enhance then
        let
          item = "resolve [!UNAVAIL=return]";
        in
        if builtins.elem item defns then
          lib.filter (x: x != item) defns
        else
          throw ''
            Error trying to remove non-existing element `${item}` from config.system.nssDatabases.hosts.

            Check the value of `system.nssDatabases.hosts` in ${builtins.head options.services.resolved.enable.declarations},
            and update `options.system.nssDatabases.hosts` in ${__curPos.file} accordingly.
          ''
      else
        defns;
  };

  config = lib.mkIf cfg.enhance {
    environment.etc."resolv.conf".text = lib.mkForce ''
      nameserver ${builtins.elemAt cfg.settings.bind 0}
    '';

    services.resolved.enable = true;
    # When resolved enabled, /etc/nsswitch.conf will have `hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns`,
    # which will make gethostbyname (apps like `ping` `firefox`) prefer systemd-resolved, and ignore /etc/resolv.conf.
    # Currently using custom `options.system.nssDatabases.hosts` hack (see above) to remove `resolve [!UNAVAIL=return]`,
    # make tools like `dig` and `ping` have almost the same result.
    # Another fix is prepending `files myhostname dns [!UNAVAIL=return]`:
    # system.nssDatabases.hosts = lib.mkBefore [ "files myhostname dns [!UNAVAIL=return]" ];

    services.smartdns.enable = true;
    services.smartdns.settings = {
      bind = "127.0.0.52";
      cache-size = 4096;
      force-AAAA-SOA = true;
      force-qtype-SOA = 65;
      # Support /etc/hosts as fallback, for apps that skip nss, or false nsswitch.conf config like missing `files`
      hosts-file = "/etc/hosts";
      nameserver = [
        "/detectportal.firefox.com/local"
        "/lan/local"
        "/netease.com/local"
        "/google.com/global"
        "/githubusercontent.com/global"
      ];
      prefetch-domain = true;
      rr-ttl-min = 600;
      serve-expired = true;
      server = "127.0.0.54 -group local";
      server-quic = "223.5.5.5";
      # https://pymumu.github.io/smartdns/config/edns-client-subnet/
      # server-tls = "9.9.9.9 -group global -subnet 202.101.172.35";
      server-tls = "1.0.0.1 -group global";
      user = "nobody";
    };
  };
}
