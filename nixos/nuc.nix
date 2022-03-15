{ config, lib, pkgs, ... }:

{
  fileSystems."/".options = [ "compress-force=zstd" ];
  fileSystems."/srv".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  networking.useDHCP = false;
  networking.interfaces.vlan1.useDHCP = true;
  networking.vlans.vlan1.id = 1;
  networking.vlans.vlan1.interface = "eno1";
}
