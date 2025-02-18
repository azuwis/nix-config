{
  inputs,
  withSystem,
  ...
}:

let
  mkNixos = import ./mk-system.nix {
    inherit inputs withSystem;
    defaultSystem = "x86_64-linux";
    defaultModules = [ ../nixos ];
    applyFunction =
      args@{ ... }:
      args.nixpkgs.lib.nixosSystem {
        modules = [
          # Jovian use nixpkgs.overlays option, and block readOnlyPkgs
          # inputs.nixpkgs.nixosModules.readOnlyPkgs
          { nixpkgs.pkgs = args.pkgs; }
        ] ++ args.modules;
        specialArgs = {
          inherit (args)
            inputs
            inputs'
            lib
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
        (import ../overlays/jovian.nix)
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
