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
    file = "${inputs.my.outPath}/shadowsocks.age";
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
  # Set `Disabled` should prevent `darwin-rebuild switch` from starting up the services again,
  # useful when `scinet off`
  # launchd.daemons.scidns-resolv.serviceConfig.Disabled = true;
  # launchd.daemons.sciroute.serviceConfig.Disabled = true;
  # Set `KeepAlive.AfterInitialDemand` should prevent the services start up when login, but it does not work
  # launchd.daemons.scidns-resolv.serviceConfig.KeepAlive.AfterInitialDemand = true;
  # launchd.daemons.sciroute.serviceConfig.KeepAlive.AfterInitialDemand = true;
}
