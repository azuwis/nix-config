{ self, ... }: {
  flake.overlays.default = import ../overlay.nix;

  perSystem = { lib, system, ... }:
    let
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default self.inputs.nvidia-patch.overlay ];
        config.allowUnfree = true;
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
