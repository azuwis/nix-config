{ self, lib, ... }: {
  flake.overlays.default = lib.composeManyExtensions [
    self.overlays.packages
    (import ../overlays/default.nix)
  ];
  flake.overlays.packages = import "${self.inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name;
  flake.overlays.jovian = import ../overlays/jovian.nix;

  perSystem = { lib, system, ... }:
    let
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    in
    {
      _module.args.pkgs = pkgs;

      packages = lib.filterAttrs
        (_: value: value ? type && value.type == "derivation")
        (builtins.mapAttrs
          (name: _: pkgs.${name})
          (self.overlays.default { } { }));
    };
}
