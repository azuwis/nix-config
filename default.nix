{ ... }:
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake-compat = fetchTarball {
    url =
      lock.nodes.flake-compat.locked.url
        or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
  self = import flake-compat { src = ./.; };
  nixpkgs = self.defaultNix.inputs.nixpkgs.outPath;
  packages = import nixpkgs {
    overlays = [
      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./pkgs/by-name)
      (import ./overlays/default.nix)
    ];
  };
in
# nix-update expect nixpkgs-like repo https://discourse.nixos.org/t/25274
packages // self.defaultNix
