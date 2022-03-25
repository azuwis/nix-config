{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-utm.nix
    ./hardware-utm.nix
  ];
  fileSystems."/".options = [ "compress-force=zstd" ];
  networking.hostName = "utm";
}
