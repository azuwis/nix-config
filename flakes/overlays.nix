{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.overlays.packages = import "${inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name;
  flake.overlays.jovian = import ../overlays/jovian.nix;

  flake.overlays.default = lib.composeManyExtensions [
    inputs.agenix.overlays.default
    self.overlays.packages
    (import ../overlays/default.nix { inherit inputs; })
    (import ../overlays/lix.nix)
  ];

  perSystem =
    { lib, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowAliases = false;
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
        overlays = [ self.overlays.default ];
      };
    in
    {
      _module.args.pkgs = pkgs;

      packages = lib.filterAttrs (_: value: value ? type && value.type == "derivation") (
        builtins.mapAttrs (name: _: pkgs.${name}) (self.overlays.default { } { })
      );
    };
}
