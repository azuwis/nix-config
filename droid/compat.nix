{ config, lib, pkgs, ... }:

{
  programs.direnv.nix-direnv.enableFlakes = true;
}
