{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

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
    file = "${inputs.my}/shadowsocks.age";
    path = "/etc/shadowsocks/config.json";
    symlink = false;
  };
  services.shadowsocks = {
    enable = true;
    package = pkgs.shadowsocks-rust;
    bin = "sslocal";
    config = config.age.secrets.shadowsocks.path;
    user = "root";
  };
  services.scidns.enable = true;
  services.sciroute.enable = true;
}
