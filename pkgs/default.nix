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
pkgs
