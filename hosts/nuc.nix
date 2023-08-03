{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-nuc.nix
  ];
  powerManagement.cpuFreqGovernor = "schedutil";
  fileSystems."/".options = [ "compress-force=zstd" ];
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

  my.evdevhook.enable = true;
  my.desktop.enable = true;
  my.dualsensectl.enable = true;
  my.hass.enable = true;
  my.intelGpu.enable = true;
  # my.moonlight-cemuhook.enable = true;
  # my.moonlight-cemuhook.package = pkgs.moonlight-git;
  my.photoprism.enable = true;
  my.retroarch.enable = true;
  my.torrent.enable = true;
  my.uxplay.enable = true;
  my.zramswap.enable = true;

  hm.my.jslisten.enable = true;
  hm.my.jslisten.settings = {
    # L+PS
    BotW = {
      program = ''sh -c "dualsensectl trigger right feedback 5 8; moonlight stream office BotW"'';
      button1 = 4;
      button2 = 10;
    };
  };

  hm.my.swayidle.enable = false;

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
}
