{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-nuc.nix
    ./hardware-nuc.nix
    ../nixos/hass
    ../nixos/nginx.nix
    ../nixos/samba.nix
    ../nixos/torrent.nix
    ../nixos/uxplay.nix
  ];
  hm.imports = [
    ../nixos/uxplay.nix
  ];
  powerManagement.cpuFreqGovernor = "schedutil";
  fileSystems."/srv".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  networking.interfaces.eno1.useDHCP = false;
  networking.vlans.vlan1.id = 1;
  networking.vlans.vlan1.interface = "eno1";
  networking.interfaces.vlan1.useDHCP = true;
  networking.vlans.vlan5.id = 5;
  networking.vlans.vlan5.interface = "eno1";
  networking.interfaces.vlan5.ipv4 = {
    addresses = [{ address = "192.168.20.250"; prefixLength = 24; }];
    routes = [{ address = "240.0.0.0"; prefixLength = 4; }];
  };
  services.beesd.filesystems = {
    nixos = {
      spec = "/";
      hashTableSizeMB = 128;
      verbosity = "info";
      extraOptions = [ "--loadavg-target" "2.0" ];
    };
  };
  services.greetd.settings.initial_session = {
    command = "sway";
    user = config.my.user;
  };
  # hardware.bluetooth.enable = true;
}
