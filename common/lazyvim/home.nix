{ config, lib, pkgs, ... }:

{
  imports = [
    ./base
    ./ansible
    ./bash
    ./custom
    ./helm
    ./neogit
    ./nix
    ./nord
    ./terraform
  ];
}
