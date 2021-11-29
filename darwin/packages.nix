{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils-full
    daemon
    hydra-check
    wireguard
  ];
}
