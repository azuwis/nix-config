{ config, lib, pkgs, ... }:

let
  smartnet = pkgs.writeScriptBin "smartnet" ''
    smartdns_resolv_script=${config.services.smartdns.resolv.script}
    is_on() {
      sudo launchctl list "${config.launchd.daemons.smartdns-resolv.serviceConfig.Label}" 1>/dev/null 2>/dev/null
    }
    on() {
      sudo "$smartdns_resolv_script" enable
      sudo pfctl -e -f /etc/pf.conf 2>&1 | tail -n1
    }
    off() {
      sudo "$smartdns_resolv_script" disable
      sudo pfctl -d 2>&1 | tail -n1
    }
    status() {
      if is_on
      then
        echo "on"
      else
        echo "off"
      fi
    }
    toggle() {
      if is_on
      then
        off
      else
        on
      fi
    }
    action="$1"
    if [ -n "$action" ]
    then
      "$action"
    else
      status
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
