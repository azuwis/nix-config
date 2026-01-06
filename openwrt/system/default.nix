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
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "OpenWrt";
    };
  };

  config = lib.mkIf cfg.enable {
    files.file."/etc/dropbear/authorized_keys".text = lib.concatStringsSep "\n" config.my.keys;
    files.file."etc/sysctl.conf".text = ''
      net.netfilter.nf_conntrack_max=32768
    '';
    files.file."/etc/uci-defaults/99-system".text = ''
      uci batch <<EOF
      set dhcp.@dnsmasq[0].cachesize=1024
      add_list dhcp.@dnsmasq[0].rebind_domain='/netease.com/'
      set dropbear.@dropbear[0].PasswordAuth='0'
      set dropbear.@dropbear[0].RootPasswordAuth='0'
      set system.@system[0].hostname='${cfg.hostname}'
      set system.@system[0].log_buffer_size='256'
      set system.@system[0].timezone='CST-8'
      set system.@system[0].zonename='Asia/Shanghai'
      EOF
    '';
  };
}
