{ config, lib, pkgs, darwinNixpkgs, ... }:

{
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = flakes nix-command
    keep-outputs = true
    tarball-ttl = 43200
  '';
  nix.nixPath = [ "nixpkgs=${darwinNixpkgs}" ];
  nix.registry.nixpkgs.flake = darwinNixpkgs;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ./overlays.nix;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
