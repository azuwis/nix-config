{ config, lib, pkgs, ... }:

{
  fileSystems."/".options = [ "compress=zstd" ];
  networking.hostName = "utm";
  networking.interfaces.enp0s10.useDHCP = true;
}
