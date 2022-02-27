{ config, lib, pkgs, darwinNixpkgs, ... }:

let
  nixpkgs = darwinNixpkgs;
in

{
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = flakes nix-command
    keep-outputs = true
    tarball-ttl = 43200
  '';
  environment.etc."nix/inputs/nixpkgs".source = nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
  nix.registry.nixpkgs.flake = nixpkgs;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ./overlays.nix;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
