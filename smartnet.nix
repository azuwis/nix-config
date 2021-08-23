{ config, lib, pkgs, ... }:

{
  services.redsocks2.enable = true;
  services.redsocks2.extraConfig = ''
    tcpdns {
      bind = "127.0.0.1:55";
      tcpdns1 = "8.8.8.8";
      timeout = 4;
    }
  '';
  services.shadowsocks.enable = true;
  services.smartdns.enable = true;
}
