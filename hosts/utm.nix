{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > utm-hardware.nix
    ./utm-hardware.nix
  ];
  fileSystems."/".options = [ "compress=zstd" ];
  networking.hostName = "utm";
}
