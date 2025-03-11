{
  inputs,
  lib,
  ...
}:

let
  mkNixos =
    host:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [ (../hosts + "/${host}.nix") ];
    };
in
{
  flake.nixosConfigurations = lib.genAttrs [
    "hyperv"
    "nuc"
    "steamdeck"
    "tuf"
    "utm"
    "wsl"
  ] mkNixos;
}
