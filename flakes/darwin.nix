{
  extraModules ? [ ],
}:
let
  inputs = import ../inputs { };
  lib = import ../lib;

  mkDarwin =
    host:
    import (inputs.nix-darwin.outPath + "/eval-config.nix") {
      inherit lib;
      modules = [
        (../hosts + "/${host}.nix")
      ]
      ++ extraModules;
    };
in

lib.genAttrs [
  "mbp"
] mkDarwin
