{ config, lib, pkgs, ... }:

{
  imports = [
    ./system.nix
    ../modules/photoprism
    ../modules/qbittorrent
  ];

  hm.imports = [
    ./gnupg.nix
    ./packages.nix
  ];
}
