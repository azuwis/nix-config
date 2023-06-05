{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-office.nix
    ./hardware-office.nix
    ../nixos/nvidia.nix
    ../nixos/sunshine.nix
  ];
  hm.imports = [
    ../nixos/nvidia.nix
    ../nixos/retroarch.nix
    ../nixos/sunshine.nix
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "office";
  # hardware.bluetooth.enable = true;

  my.desktop.enable = true;
  hm.my.desktop.enable = true;
}
