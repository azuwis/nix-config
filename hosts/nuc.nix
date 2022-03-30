{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-nuc.nix
    ./hardware-nuc.nix
    ../nixos/hass
    ../nixos/nginx.nix
    ../nixos/rpiplay.nix
    ../nixos/samba.nix
    ../nixos/torrent.nix
  ];
  powerManagement.cpuFreqGovernor = "schedutil";
  fileSystems."/".options = [ "compress-force=zstd" ];
  fileSystems."/srv".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  networking.interfaces.eno1.useDHCP = false;
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
