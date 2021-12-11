{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils-full
    daemon
    element-desktop
    hydra-check
  ];
}
