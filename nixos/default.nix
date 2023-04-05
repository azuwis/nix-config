{ config, lib, pkgs, ... }:

{
  imports = [
    ./system.nix
    ../modules/qbittorrent
  ];

  hm.imports = [
    ./gnupg.nix
    ./packages.nix
  ];
}
