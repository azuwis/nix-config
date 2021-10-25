{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pinentry-curses
  ];
}
