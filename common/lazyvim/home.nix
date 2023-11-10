{ config, lib, pkgs, ... }:

{
  imports = [
    ./base
    ./ansible
    ./neogit
    ./nix
    ./nord
    ./terraform
  ];
}
