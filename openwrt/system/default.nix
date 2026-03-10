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
    files.file."etc/sysctl.conf".text = lib.mkMerge [
      "net.netfilter.nf_conntrack_max=32768"
      # Add trailing newline
      (lib.mkAfter "")
    ];
    files.file."etc/uci-defaults/96-root-password".text = ''
      root_password_hash=$(uci -q get 'system.@system[0].password')
      if [ -n "$root_password_hash" ]; then
        sed -i "s|^root:[^:]*|root:$root_password_hash|g" /etc/shadow
      fi
    '';
    uci = {
      dhcp."@dnsmasq[0]".cachesize = "1024";
      dhcp."@dnsmasq[0]".localuse = "1"; # Always use dnsmasq as nameserver in resolv.conf
      dhcp."@dnsmasq[0]".rebind_domain = [ "/netease.com/" ];
      dhcp.lan.force = "1"; # Skip checking other DHCP servers in lan to reduce startup time
      dhcp.lan.leasetime = "72h";
      dhcp.lan.limit = "245";
      dhcp.lan.start = "10";
      dropbear."@dropbear[0]".PasswordAuth = "0";
      dropbear."@dropbear[0]".RootPasswordAuth = "0";
      system."@system[0]".log_buffer_size = "256";
      system."@system[0]".timezone = "CST-8";
      system."@system[0]".zonename = "Asia/Shanghai";
    };
  };
}
