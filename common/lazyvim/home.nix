{ config, lib, pkgs, ... }:

{
  imports = [
    ./base
    ./ansible
    ./nix
    ./nord
    ./terraform
  ];
}
