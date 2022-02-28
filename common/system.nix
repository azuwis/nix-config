inputs: { config, lib, pkgs, ... }:

{
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = flakes nix-command
    keep-outputs = true
    tarball-ttl = 43200
  '';
  environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ./overlays.nix;
  programs.zsh.enable = true;
  time.timeZone = "Asia/Shanghai";
}
