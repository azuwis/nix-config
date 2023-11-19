{ config, lib, pkgs, ... }:

{
  imports = [
    ./base
    ./ansible
    ./bash
    ./custom
    ./neogit
    ./nix
    ./nord
    ./terraform
  ];
}
