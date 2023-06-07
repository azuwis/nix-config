{ config, lib, pkgs, ... }:

{
  imports = lib.my.getModules [ ../modules/nixos ];

  hm.imports = [
    ./gnupg.nix
  ] ++ lib.my.getHmModules [ ../modules/nixos ];
}
