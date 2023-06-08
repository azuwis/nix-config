{ config, lib, pkgs, ... }:

{
  imports = lib.my.getModules [ ../modules/nixos ];

  hm.imports = lib.my.getHmModules [ ../modules/nixos ];
}
