{ config, lib, pkgs, ... }:

let
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
  services.shadowsocks = {
    enable = true;
    package = pkgs.shadowsocks-rust;
    programArgs = [ "${pkgs.shadowsocks-rust}/bin/sslocal" "-c" config.age.secrets.shadowsocks.path ];
    user = "root";
  };
  services.scidns.enable = true;
  services.sciroute.enable = true;
}
