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
  self = flake.defaultNix;
  nixpkgs = self.inputs.nixpkgs.outPath;
  pkgs = import nixpkgs {
    overlays = (import ./overlays { inherit (self) inputs; }) ++ overlays;
  };
in
# nix-update expect nixpkgs-like repo
# https://discourse.nixos.org/t/25274
# https://github.com/jtojnar/nixfiles/blob/master/default.nix
pkgs // self
