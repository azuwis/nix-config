{ config, lib, pkgs, ... }:

let
  shadowsocks = pkgs.shadowsocks-rust.overrideAttrs(o: {
    cargoBuildFlags = [ "--features=aead-cipher-extra,local-dns,local-http-native-tls,local-redir,local-tun,stream-cipher" ];
    doCheck = false;
  });
  scinetScript = pkgs.substituteAll {
    src = ./scinet.sh;
    name = "scinet";
    dir = "bin";
    isExecutable = true;
    scidns_resolv_script = config.services.scidns.resolv.script;
    sciroute_script = config.services.sciroute.script;
  };
in

{
  environment.systemPackages = [ scinetScript ];
  age.secrets.shadowsocks = {
    file = "/etc/age/shadowsocks.age";
    path = "/etc/shadowsocks/config.json";
  };
  services.shadowsocks.enable = true;
  services.shadowsocks.package = shadowsocks;
  services.shadowsocks.programArgs = [ "${shadowsocks}/bin/sslocal" "-c" config.age.secrets.shadowsocks.path ];
  services.shadowsocks.user = "root";
  services.scidns.enable = true;
  services.sciroute.enable = true;
}
