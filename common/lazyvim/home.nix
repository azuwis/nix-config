{ config, lib, pkgs, ... }:

{
  imports = [
    ./base
    ./ansible
    ./custom
    ./neogit
    ./nix
    ./nord
    ./terraform
  ];
}
