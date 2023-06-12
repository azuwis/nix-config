{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-nuc.nix
    ./hardware-nuc.nix
    ../nixos/hass
    ../nixos/nginx.nix
    # ../nixos/sunshine.nix
    ../nixos/torrent.nix
  ];
  hm.imports = [
    { home.packages = [ pkgs.moonlight-qt ]; }
    # ../nixos/sunshine.nix
    ../nixos/retroarch.nix
  ];
  powerManagement.cpuFreqGovernor = "schedutil";
  fileSystems."/srv".options = [ "compress=zstd" ];
  networking.hostName = "nuc";
  # networking.useDHCP = false;
  # networking.vlans.vlan1.id = 1;
  # networking.vlans.vlan1.interface = "eno1";
  # networking.interfaces.vlan1.useDHCP = true;
  # networking.vlans.vlan5.id = 5;
  # networking.vlans.vlan5.interface = "eno1";
  # networking.interfaces.vlan5.ipv4 = {
  #   addresses = [{ address = "192.168.20.250"; prefixLength = 24; }];
  #   routes = [{ address = "240.0.0.0"; prefixLength = 4; }];
  # };
  services.beesd.filesystems = {
    nixos = {
      spec = "/";
      hashTableSizeMB = 128;
      verbosity = "info";
      extraOptions = [ "--loadavg-target" "2.0" ];
    };
  };

  my.desktop.enable = true;
  my.dsdrv.enable = true;
  my.dsdrv.settings.host = "0.0.0.0";
  my.intelGpu.enable = true;
  my.photoprism.enable = true;
  my.samba.enable = true;
  my.uxplay.enable = true;
  my.zramswap.enable = true;

  hm.my.swayidle.enable = false;
}
