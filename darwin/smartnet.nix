{ config, lib, pkgs, ... }:

let
  shadowsocks = pkgs.shadowsocks-rust.overrideAttrs(o: {
    cargoBuildFlags = [ "--features=aead-cipher-extra,local-dns,local-http-native-tls,local-redir,local-tun,stream-cipher" ];
    doCheck = false;
  });
  smartnet = pkgs.writeScriptBin "smartnet" ''
    scidns_resolv_script=${config.services.scidns.resolv.script}
    route_script=${config.services.route.script}
    is_on() {
      sudo launchctl list "${config.launchd.daemons.scidns-resolv.serviceConfig.Label}" 1>/dev/null 2>/dev/null
    }
    on() {
      sudo "$scidns_resolv_script" enable
      sudo "$route_script" enable
    }
    off() {
      sudo "$scidns_resolv_script" disable
      sudo "$route_script" disable
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
  age.secrets.shadowsocks = {
    file = "/etc/age/shadowsocks.age";
    path = "/etc/shadowsocks/config.json";
  };
  services.shadowsocks.enable = true;
  services.shadowsocks.package = shadowsocks;
  services.shadowsocks.programArgs = [ "${shadowsocks}/bin/sslocal" "-c" config.age.secrets.shadowsocks.path ];
  services.shadowsocks.user = "root";
  services.scidns.enable = true;
  services.route.enable = true;
}
