{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (retroarch.override {
      cores = with libretro; [
        genesis-plus-gx
      ];
    })
  ];
}
