{ self, lib, ... }:
{
  flake.overlays.packages = import "${self.inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name;
  flake.overlays.yuzu = final: prev: {
    yuzu-ea =
      lib.optionalAttrs final.stdenv.isLinux
        self.inputs.yuzu.packages.${final.system}.early-access;
  };
  flake.overlays.jovian = import ../overlays/jovian.nix;

  flake.overlays.default = lib.composeManyExtensions [
    self.overlays.packages
    self.overlays.yuzu
    (import ../overlays/default.nix)
  ];

  perSystem =
    { lib, system, ... }:
    let
      pkgs = import self.inputs.nixpkgs {
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
