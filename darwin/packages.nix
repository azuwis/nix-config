{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils-full
    hydra-check
    wireguard
  ];
}
