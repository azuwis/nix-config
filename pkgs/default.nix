{
  # Required by nixpkgs-hammering
  overlays ? [ ],
  ...
}:

let
  inputs = import ../inputs;
  pkgs = import "${inputs.nixpkgs.outPath}" {
    config = import ../config.nix;
    overlays = (import ../overlays { }) ++ overlays;
  };
in
# nix-update expect nixpkgs-like repo
# https://discourse.nixos.org/t/25274
# https://github.com/jtojnar/nixfiles/blob/master/default.nix
pkgs
