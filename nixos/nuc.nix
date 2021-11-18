{ config, lib, pkgs, ... }:

{
  fileSystems."/".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  networking.interfaces.vlan1.useDHCP = true;
  networking.vlans.vlan1.id = 1;
  networking.vlans.vlan1.interface = "eno1";
}
