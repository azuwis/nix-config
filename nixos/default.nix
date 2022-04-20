{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./system.nix
    ../modules/qbittorrent
    inputs.home-manager.nixosModules.home-manager
  ];

  hm.imports = [
    ./packages.nix
  ];
}
