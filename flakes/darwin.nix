{
  inputs,
  lib,
  ...
}:

let
  mkDarwin =
    host:
    inputs.darwin.lib.darwinSystem {
      modules = [ (../hosts + "/${host}.nix") ];
    };
in
{
  flake.darwinConfigurations = lib.genAttrs [
    "mbp"
  ] mkDarwin;
}
