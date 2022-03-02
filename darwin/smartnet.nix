{ config, lib, pkgs, ... }:

let
  smartnet = pkgs.writeScriptBin "smartnet" ''
    smartdns_resolv_script=${config.services.smartdns.resolv.script}
    on() {
      sudo "$smartdns_resolv_script" enable
      sudo pfctl -e -f /etc/pf.conf 2>&1 | tail -n1
    }
    off() {
      sudo "$smartdns_resolv_script" disable
      sudo pfctl -d 2>&1 | tail -n1
    }
    action="$1"
    if [ -n "$action" ]
    then
      "$action"
    else
      if sudo launchctl list "${config.launchd.daemons.smartdns-resolv.serviceConfig.Label}" 1>/dev/null 2>/dev/null
      then
        off
      else
        on
      fi
    fi
  '';
in

{
  environment.systemPackages = [ smartnet ];
  services.redsocks2.enable = true;
  services.redsocks2.extraConfig = ''
    tcpdns {
      bind = "127.0.0.1:55";
      tcpdns1 = "8.8.8.8";
      timeout = 4;
    }
  '';
  age.secrets.shadowsocks = {
    file = "/etc/age/shadowsocks.age";
    path = "/etc/shadowsocks/config.json";
    owner = config.users.users.shadowsocks.name;
    group = config.users.users.shadowsocks.name;
  };
  services.shadowsocks.enable = true;
  services.shadowsocks.config = config.age.secrets.shadowsocks.path;
  services.smartdns.enable = true;
}
