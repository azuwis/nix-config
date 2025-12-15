let
  inputs = import ../inputs;
  nixpkgs = inputs.nixpkgs.outPath;
  lib = import ../lib;

  mkNixos =
    host:
    import (nixpkgs + "/nixos/lib/eval-config.nix") {
      # No need to pass nixpkgs or pkgs, eval-config.nix will import the same
      # nixpkgs that contains it, see nixpkgs/nixos/modules/misc/nixpkgs.nix
      system = null;
      modules = [
        (../hosts + "/${host}.nix") # compatible syntax with nix 2.3
      ];
    };
in

lib.genAttrs [
  "aor"
  "hyperv"
  "jovian"
  "nuc"
  "utm"
  "wsl"
] mkNixos
