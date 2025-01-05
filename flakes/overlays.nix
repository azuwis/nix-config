{
  inputs,
  self,
  lib,
  ...
}:

let
  overlays = import ../overlays { inherit inputs; };
in
{
  perSystem =
    { lib, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config = {
          allowAliases = false;
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
    in
    {
      _module.args.pkgs = pkgs;

      packages = lib.filterAttrs (_: value: value ? type && value.type == "derivation") (
        builtins.mapAttrs (name: _: pkgs.${name}) (lib.composeManyExtensions overlays null null)
      );
    };
}
