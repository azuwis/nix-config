{
  inputs,
  self,
  withSystem,
  ...
}:

let
  mkNixos = import ./mk-system.nix {
    inherit inputs self withSystem;
    defaultSystem = "x86_64-linux";
    defaultModules = [ ../nixos ];
    applyFunction =
      args@{ ... }:
      args.nixpkgs.lib.nixosSystem {
        inherit (args) system modules;
        specialArgs = {
          inherit (args)
            inputs
            inputs'
            lib
            pkgs
            ;
        };
      };
  };
in
{
  flake.nixosConfigurations = {
    nuc = mkNixos { modules = [ ../hosts/nuc.nix ]; };

    tuf = mkNixos {
      modules = [ ../hosts/tuf.nix ];
    };

    steamdeck = mkNixos {
      # Use same nixpkgs as jovian, comment `inputs.jovian.inputs.nixpkgs.follows` in flake.nix if enable
      # nixpkgs = inputs.jovian.inputs.nixpkgs;
      overlays = [
        inputs.jovian.overlays.default
        self.overlays.jovian
      ];
      modules = [ ../hosts/steamdeck.nix ];
    };

    utm = mkNixos {
      system = "aarch64-linux";
      modules = [ ../hosts/utm.nix ];
    };

    hyperv = mkNixos { modules = [ ../hosts/hyperv.nix ]; };

    wsl = mkNixos { modules = [ ../hosts/wsl.nix ]; };
  };
}
