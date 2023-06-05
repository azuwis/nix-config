{ config, lib, pkgs, ... }:

{
  my.desktop.enable = true;
  hm.my = {
    desktop.enable = true;
    swayidle.enable = false;
  };

  imports = [
    # nixos-generate-config --show-hardware-config > hardware-nuc.nix
    ./hardware-nuc.nix
    ../nixos/android.nix
    ../nixos/hass
    ../nixos/nginx.nix
    ../nixos/photoprism.nix
    ../nixos/samba.nix
    # ../nixos/sunshine.nix
    ../nixos/torrent.nix
    ../nixos/uxplay.nix
    ../nixos/zramswap.nix
  ];
  hm.imports = [
    { home.packages = [ pkgs.moonlight-qt ]; }
    ../nixos/uxplay.nix
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
  # to start initial_session again, run `/run/greetd.run; systemctl restart greetd`
  services.greetd.settings.initial_session = {
    command = "sway";
    user = config.my.user;
  };
  hardware.bluetooth.enable = true;
}
