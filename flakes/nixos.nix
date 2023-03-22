{ inputs, withSystem, lib, ... }:

let
  mkNixos = { system ? "x86_64-linux", modules ? [], desktop ? true }:
  withSystem system ({ lib, pkgs, system, ... }: inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs lib pkgs; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      ../common
      ../nixos
    ] ++ lib.optionals desktop [ ../nixos/desktop.nix ]
    ++ modules ;
  });
in {
  flake.nixosConfigurations = {
    nuc = mkNixos {
      modules = [ ../hosts/nuc.nix ];
    };

    utm = mkNixos {
      system = "aarch64-linux";
      desktop = false;
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
