{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.overlays.packages = import "${inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name;
  flake.overlays.yuzu = final: prev: {
    yuzu-ea = lib.optionalAttrs final.stdenv.isLinux inputs.yuzu.packages.${final.system}.early-access;
  };

  flake.overlays.default = lib.composeManyExtensions [
    self.overlays.packages
    self.overlays.yuzu
    (import ../overlays/default.nix)
  ];

  perSystem =
    { lib, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
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
