{ config, lib, pkgs, darwinHm, ... }:

{
  imports = [
    darwinHm.darwinModules.home-manager
    ../common
    ../common/gui.nix
  ];
  home-manager.users.${config.my.user} = { imports = [
    ../common/alacritty.nix
    ./emacs
    ./firefox.nix
    ./hmapps.nix
    ./kitty.nix
    ./packages.nix
    ./skhd.nix
  ]; };
}
