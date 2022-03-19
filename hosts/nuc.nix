{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > nuc-hardware.nix
    ./nuc-hardware.nix
    ../nixos/torrent.nix
  ];
  fileSystems."/".options = [ "compress-force=zstd" ];
  fileSystems."/srv".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  networking.useDHCP = false;
  networking.interfaces.vlan1.useDHCP = true;
  networking.vlans.vlan1.id = 1;
  networking.vlans.vlan1.interface = "eno1";
  services.beesd.filesystems = {
    nixos = {
      spec = "/";
      hashTableSizeMB = 128;
      verbosity = "info";
      extraOptions = [ "--loadavg-target" "2.0" ];
    };
  };
}
