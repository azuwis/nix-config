{ self, ... }: {
  flake.overlays.default = import ../overlay.nix;

  perSystem = { system, ... }: {
    _module.args.pkgs = import self.inputs.nixpkgs {
      inherit system;
      overlays = [ self.overlays.default self.inputs.nvidia-patch.overlay ];
      config.allowUnfree = true;
    };
  };
}
