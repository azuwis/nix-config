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
    builder.packages = [
      "diffutils"
      "tcpdump"
    ];
    files.file = {
      "etc/dropbear/authorized_keys".text = lib.concatStringsSep "\n" config.my.keys;

      # Empty file /etc/profile.d/apk-cheatsheet.hush will skip load /etc/profile.d/apk-cheatsheet.sh
      # TODO: Remove when openwrt 26 releases
      # https://github.com/openwrt/openwrt/blob/df45ed2da0afb3c2c4dce567338eaa3ef099217a/package/base-files/files/etc/profile#L35
      "etc/profile.d/apk-cheatsheet.hush".text = "";

      "etc/sysctl.conf".text = lib.mkMerge [
        "net.netfilter.nf_conntrack_max=32768"
        (lib.mkAfter "") # Add trailing newline
      ];

      # Rename dhcp.@dnsmasq[0] to dhcp.main, for `uci.dhcp.lan.instance` and `uci.dhcp.wan.instance`
      "usr/libexec/uci-defaults/dhcp-dnsmasq-rename.uc".source = ./dhcp-dnsmasq-rename.uc;
      "etc/uci-defaults/90-dhcp-dnsmasq-rename".text = ''
        ucode /usr/libexec/uci-defaults/dhcp-dnsmasq-rename.uc
      '';

      # Radios are not consistent between fresh install, sort them by band (2g,
      # 5g, 6g) so radio0 is always 2g, radio1 is 5g, etc.
      "usr/libexec/uci-defaults/wireless-order.uc".source = ./wireless-order.uc;
      "etc/uci-defaults/90-wireless-order".text = ''
        ucode /usr/libexec/uci-defaults/wireless-order.uc
      '';

      # etc/uci-defaults/92-uci-import, in ../uci/default.nix
      # etc/uci-defaults/95-sops-enc, in ../sops/default.nix

      "etc/uci-defaults/96-root-password".text = ''
        root_password_hash=$(uci -q get 'system.@system[0].password')
        if [ -n "$root_password_hash" ]; then
          sed -i "s|^root:[^:]*|root:$root_password_hash|g" /etc/shadow
        fi
      '';

      "etc/uci-defaults/99-chmod-etc-config".text = ''
        chmod 600 /etc/config/*
      '';
    };
    uci = {
      dhcp.main.cachesize = "1024";
      dhcp.main.localuse = "1"; # Always use dnsmasq as nameserver in resolv.conf
      dhcp.lan.force = "1"; # Skip checking other DHCP servers in lan to reduce startup time
      dhcp.lan.instance = "main"; # Only apply to main dnsmasq
      dhcp.lan.leasetime = "72h";
      dhcp.lan.limit = "245"; # DHCP IP 10~254, 245 total
      dhcp.lan.start = "10"; # Static IP 1~9
      dhcp.wan.instance = "main"; # Only apply to main dnsmasq
      dropbear."@dropbear[0]".PasswordAuth = "0";
      dropbear."@dropbear[0]".RootPasswordAuth = "0";
      system."@system[0]".log_buffer_size = "1024"; # Size in KiB, for logread
      system."@system[0]".timezone = "CST-8";
      system."@system[0]".zonename = "Asia/Shanghai";
    };
  };
}
