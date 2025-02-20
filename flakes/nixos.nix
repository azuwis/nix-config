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
      {
        extraArgs,
        inputs',
        inputs,
        lib,
        modules,
        nixpkgs,
        pkgs,
        ...
      }:
      nixpkgs.lib.nixosSystem {
        modules =
          lib.optionals (!(extraArgs ? readOnlyPkgs && extraArgs.readOnlyPkgs == false)) [
            inputs.nixpkgs.nixosModules.readOnlyPkgs
          ]
          ++ [
            { nixpkgs.pkgs = pkgs; }
          ]
          ++ modules;
        specialArgs = {
          inherit
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
      modules = [ ../hosts/steamdeck.nix ];
      # Jovian use nixpkgs.overlays option, and block readOnlyPkgs
      readOnlyPkgs = false;
    };

    utm = mkNixos {
      system = "aarch64-linux";
      modules = [ ../hosts/utm.nix ];
    };

    hyperv = mkNixos { modules = [ ../hosts/hyperv.nix ]; };

    wsl = mkNixos { modules = [ ../hosts/wsl.nix ]; };
  };
}
