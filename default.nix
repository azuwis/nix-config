{
  # Required by nixpkgs-hammering
  overlays ? [ ],
  ...
}:

let
  flake-compat =
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      inherit (lock.nodes.${lock.nodes.${lock.root}.inputs.flake-compat}.locked)
        owner
        repo
        rev
        narHash
        ;
    in
    fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = narHash;
    };
  flake = import flake-compat {
    src = ./.;
  };
  nixpkgs = flake.defaultNix.inputs.nixpkgs.outPath;
  packages = import nixpkgs {
    overlays = [
      # For `builtins.unsafeGetAttrPos "src"` to work in scripts/update.nix,
      # `flake.defaultNix.overlays.default` can not be used here.
      # Update this if `flake.overlays.default` changed in `flakes/overlay.nix`.
      flake.defaultNix.inputs.agenix.overlays.default
      (import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ./pkgs/by-name)
      (import ./overlays/default.nix { inherit (flake.defaultNix) inputs; })
      (import ./overlays/lix.nix)
    ] ++ overlays;
  };
in
# nix-update expect nixpkgs-like repo
# https://discourse.nixos.org/t/25274
# https://github.com/jtojnar/nixfiles/blob/master/default.nix
packages // flake.defaultNix
