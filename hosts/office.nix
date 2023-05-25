{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-office.nix
    ./hardware-office.nix
  ];
  hm.imports = [
    ../nixos/retroarch.nix
  ];
  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostName = "office";
  # hardware.bluetooth.enable = true;
}