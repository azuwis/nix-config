{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-utm.nix
  ];
  networking.hostName = "utm";
}
