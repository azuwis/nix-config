{
  extraModules ? [ ],
}:
let
  lib = import ../lib;

  mkSolo =
    host:
    lib.evalModules {
      class = "solo";
      modules = [
        (../hosts + "/${host}.nix")
      ]
      ++ extraModules;
    };
in

lib.genAttrs [
  "solo"
  "solo-shell"
  "solo-single"
] mkSolo
