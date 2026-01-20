{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.system;
in

{
  options.system = {
    enable = lib.mkEnableOption "system";
  };

  config = lib.mkIf cfg.enable {
    files.file."etc/dropbear/authorized_keys".text = lib.concatStringsSep "\n" config.my.keys;
    files.file."etc/sysctl.conf".text = ''
      net.netfilter.nf_conntrack_max=32768
    '';
    uci = {
      dhcp."@dnsmasq[0]".cachesize = "1024";
      dhcp."@dnsmasq[0]".rebind_domain = [ "/netease.com/" ];
      dhcp.lan.leasetime = "72h";
      dhcp.lan.limit = "245";
      dhcp.lan.start = "10";
      dropbear.PasswordAuth = "0";
      dropbear.RootPasswordAuth = "0";
      system.log_buffer_size = "256";
      system.timezone = "CST-8";
      system.zonename = "Asia/Shanghai";
    };
  };
}
