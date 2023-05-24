{ config, lib, pkgs, ... }:

{
  imports = [
    ./system.nix
  ] ++ lib.my.getModules [ ../modules/nixos ];

  hm.imports = [
    ./gnupg.nix
    ./packages.nix
  ];
}
