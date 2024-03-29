{ self, ... }: {
  flake.overlays.default = import ../overlays/default.nix;
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
