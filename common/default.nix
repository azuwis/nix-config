{ config, lib, pkgs, ... }:

{
  imports = [
    ./system.nix
    ./my.nix
  ];
}
