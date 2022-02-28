{ nixpkgs }: { config, lib, pkgs, ... }:

{
  environment.etc."nix/inputs/nixpkgs".source = nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
  nix.registry.nixpkgs.flake = nixpkgs;
}
