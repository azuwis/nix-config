{ config, lib, pkgs, ...}:

{
  environment.systemPackages = [ pkgs.rpiplay ];
  networking.firewall.allowedTCPPorts = [ 7000 7100 ];
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.enable = true;
    publish.userServices = true;
  };
}
