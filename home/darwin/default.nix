{ config, lib, pkgs, darwinHm, ... }:

{
  imports = [
    darwinHm.darwinModules.home-manager
  ];
  home-manager.users.${config.my.user} = { imports = [
    ./emacs
    ./firefox.nix
    ./hmapps.nix
    ./kitty.nix
    ./packages.nix
    ./skhd.nix
  ]; };
}
