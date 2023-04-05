{ config, lib, pkgs, ... }:

{
  imports = [
    ./system.nix
  ] ++ lib.my.getModules [ ./modules ];

  hm.imports = [
    ./gnupg.nix
    ./packages.nix
  ];
}
