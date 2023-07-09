{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-office.nix
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "office";

  my.cemu.enable = true;
  my.desktop.enable = true;
  my.nvidia.enable = true;
  my.retroarch.enable = true;
  my.sunshine.enable = true;
  # hm.my.sunshine.package = pkgs.sunshine-git;

}
