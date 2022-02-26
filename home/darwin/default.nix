{ config, lib, pkgs, darwinHm, ... }:

{
  imports = [
    darwinHm.darwinModules.home-manager
  ];
  home-manager.users.${config.my.user} = { imports = [
    ../../darwin/emacs
    ../../darwin/firefox.nix
    ../../darwin/hmapps.nix
    ../../darwin/kitty.nix
    ../../darwin/packages.nix
    ../../darwin/skhd.nix
  ]; };
}
