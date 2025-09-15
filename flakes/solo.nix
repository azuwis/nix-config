let
  lib = import ../lib;

  mkSolo =
    host:
    lib.evalModules {
      modules = [
        (../hosts + "/${host}.nix")
      ];
    };
in

lib.genAttrs [
  "solo"
  "solo-shell"
] mkSolo
