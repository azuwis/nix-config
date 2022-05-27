{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-utm.nix
    ./hardware-utm.nix
  ];
  networking.hostName = "utm";
}
