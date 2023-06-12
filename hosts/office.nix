{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-office.nix
    ./hardware-office.nix
  ];
  hm.imports = [
    ../nixos/retroarch.nix
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "office";

  my.desktop.enable = true;
  my.nvidia.enable = true;
  my.sunshine.enable = true;
}
