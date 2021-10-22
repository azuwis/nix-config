{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils-full
    fmenu
    hydra-check
    wireguard
  ];
}
