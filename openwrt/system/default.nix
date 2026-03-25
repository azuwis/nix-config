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
    # Empty file /etc/profile.d/apk-cheatsheet.hush will skip load /etc/profile.d/apk-cheatsheet.sh
    # TODO: Remove when openwrt 26 releases
    # https://github.com/openwrt/openwrt/blob/df45ed2da0afb3c2c4dce567338eaa3ef099217a/package/base-files/files/etc/profile#L35
    files.file."etc/profile.d/apk-cheatsheet.hush".text = "";
    files.file."etc/sysctl.conf".text = lib.mkMerge [
      "net.netfilter.nf_conntrack_max=32768"
      (lib.mkAfter "") # Add trailing newline
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
      dhcp.lan.force = "1"; # Skip checking other DHCP servers in lan to reduce startup time
      dhcp.lan.leasetime = "72h";
      dhcp.lan.limit = "245"; # DHCP IP 10~254, 245 total
      dhcp.lan.start = "10"; # Static IP 1~9
      dropbear."@dropbear[0]".PasswordAuth = "0";
      dropbear."@dropbear[0]".RootPasswordAuth = "0";
      system."@system[0]".log_buffer_size = "1024"; # Size in KiB, for logread
      system."@system[0]".timezone = "CST-8";
      system."@system[0]".zonename = "Asia/Shanghai";
    };
  };
}
