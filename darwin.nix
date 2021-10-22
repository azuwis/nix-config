{ config, lib, pkgs, ... }:

{
  imports = import ./modules.nix { inherit lib; };
}
