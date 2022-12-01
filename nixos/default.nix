{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./system.nix
    ../modules/photoprism
    ../modules/qbittorrent
    inputs.home-manager.nixosModules.home-manager
  ];

  hm.imports = [
    ./gnupg.nix
    ./packages.nix
  ];
}
