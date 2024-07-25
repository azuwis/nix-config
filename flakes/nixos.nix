{
  inputs,
  self,
  withSystem,
  ...
}:

let
  mkNixos =
    {
      system ? "x86_64-linux",
      nixpkgs ? inputs.nixpkgs,
      config ? { },
      overlays ? [ ],
      modules ? [ ],
    }:
    withSystem system (
      {
        inputs',
        lib,
        pkgs,
        system,
        ...
      }:
      let
        customPkgs = import nixpkgs (
          lib.recursiveUpdate {
            inherit system;
            overlays = [ self.overlays.default ] ++ overlays;
            config.allowUnfree = true;
          } { inherit config; }
        );
      in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs inputs' lib;
          pkgs = if (nixpkgs != inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
        };
        modules = [ ../nixos ] ++ modules;
      }
    );
in
{
  flake.nixosConfigurations = {
    nuc = mkNixos { modules = [ ../hosts/nuc.nix ]; };

    office = mkNixos {
      overlays = [ inputs.nixpkgs-wayland.overlay ];
      modules = [ ../hosts/office.nix ];
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
