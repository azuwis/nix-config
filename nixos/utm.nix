{ config, lib, pkgs, ... }:

{
  fileSystems."/".options = [ "compress=zstd" ];
  networking.hostName = "utm";
}
