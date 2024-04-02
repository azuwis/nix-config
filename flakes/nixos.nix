{ self, withSystem, ... }:

let
  mkNixos =
    { system ? "x86_64-linux"
    , nixpkgs ? self.inputs.nixpkgs
    , config ? { }
    , overlays ? [ ]
    , modules ? [ ]
    }:
    withSystem system ({ lib, pkgs, system, ... }:
    let
      customPkgs = import nixpkgs (lib.recursiveUpdate
        {
          inherit system;
          overlays = [ self.overlays.default ] ++ overlays;
          config.allowUnfree = true;
        }
        {
          inherit config;
        }
      );
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit lib;
        inputs = self.inputs;
        pkgs = if (nixpkgs != self.inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
      };
      modules = [
        ../nixos
      ] ++ modules;
    });
in
{
  flake.nixosConfigurations = {
    nuc = mkNixos {
      config.permittedInsecurePackages = [
        # for home-assistant-chip-core
        "openssl-1.1.1w"
      ];
      modules = [ ../hosts/nuc.nix ];
    };

    office = mkNixos {
      modules = [ ../hosts/office.nix ];
    };

    steamdeck = mkNixos {
      nixpkgs = self.inputs.jovian.inputs.nixpkgs;
      overlays = [ self.inputs.jovian.overlays.default self.overlays.jovian ];
      modules = [ ../hosts/steamdeck.nix ];
    };

    utm = mkNixos {
      system = "aarch64-linux";
      modules = [ ../hosts/utm.nix ];
    };

    hyperv = mkNixos {
      modules = [ ../hosts/hyperv.nix ];
    };

    wsl = mkNixos {
      modules = [ ../hosts/wsl.nix ];
    };
  };
}
