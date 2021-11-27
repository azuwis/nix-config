{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils-full
    daemonize
    hydra-check
    wireguard
  ];
}
