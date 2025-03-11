{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../nixos
    ./hardware-utm.nix
  ];

  networking.hostName = "utm";
}
