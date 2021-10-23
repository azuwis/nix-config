{ config, lib, pkgs, ... }:

{
  home.file.".termux/termux.properties".text = ''
    bell-character=beep
  '';
}
