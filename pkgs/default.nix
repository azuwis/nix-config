{ ... }@args:

let
  inputs = import ../inputs;
  pkgs = import "${inputs.nixpkgs.outPath}" (
    args
    // {
      config = import ../config.nix // args.config or { };
      # Required by nixpkgs-hammering
      overlays = (import ../overlays { }) ++ args.overlays or [ ];
    }
  );
in
# nix-update expect nixpkgs-like repo
# https://discourse.nixos.org/t/25274
# https://github.com/jtojnar/nixfiles/blob/master/default.nix
pkgs
