{ inputs, withSystem, ... }:

let
  mkNixos = { system ? "x86_64-linux", modules ? [] }:
  withSystem system ({ lib, pkgs, system, ... }: inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs lib pkgs; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      ../common
      ../nixos
    ] ++ modules ;
  });
in {
  flake.nixosConfigurations = {
    nuc = mkNixos {
      modules = [ ../hosts/nuc.nix ];
    };

    office = mkNixos {
      modules = [ ../hosts/office.nix ];
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
