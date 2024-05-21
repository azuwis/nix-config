{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-nuc.nix ];
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
      extraOptions = [
        "--loadavg-target"
        "2.0"
      ];
    };
  };

  my.evdevhook.enable = true;
  my.desktop.enable = true;
  my.dualsensectl.enable = true;
  my.hass.enable = true;
  my.intelGpu.enable = true;
  # my.moonlight-cemuhook.enable = true;
  # my.moonlight-cemuhook.package = pkgs.moonlight-git;
  my.nix-builder-client.enable = true;
  my.photoprism.enable = true;
  my.retroarch.enable = true;
  my.torrent.enable = true;
  my.uxplay.enable = true;
  my.zramswap.enable = true;

  hm.my.jslisten.enable = true;
  hm.my.swayidle.enable = false;

  # workaround for yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  hm.programs.yambar.package = pkgs.yambar.overrideAttrs (old: {
    src = old.src.override {
      rev = "0bea49b75e2cf3fe347bce3447e9dfbaaaaf2c8d";
      hash = "sha256-hX+qCDhSQ7DKxsiUp5RZoArDE7M/MVckKHIPS5QmVhs=";
    };
  });

  environment.systemPackages = with pkgs; [ moonlight-qt ];
}
