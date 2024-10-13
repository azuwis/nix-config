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
      # For `builtins.unsafeGetAttrPos "src"` to work in scripts/update.nix,
      # `self.defaultNix.overlays.default` can not be used here.
      # Update this if `flake.overlays.default` changed in `flakes/overlay.nix`.
      self.defaultNix.inputs.agenix.overlays.default
      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./pkgs/by-name)
      self.defaultNix.overlays.yuzu
      (import ./overlays/default.nix)
      (import ./overlays/lix.nix)
    ];
  };
in
# nix-update expect nixpkgs-like repo https://discourse.nixos.org/t/25274
packages // self.defaultNix
