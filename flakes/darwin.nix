{ inputs, withSystem, ... }:

let
  mkDarwin = { system ? "aarch64-darwin", modules ? [] }:
  withSystem system ({ lib, pkgs, system, ... }: inputs.darwin.lib.darwinSystem {
    inherit system;
    specialArgs = { inherit inputs lib pkgs; };
    modules = [
      inputs.agenix.darwinModules.default
      inputs.home-manager.darwinModules.home-manager
      ../common
      ../darwin
    ] ++ modules ;
  });
in {
  flake.darwinConfigurations.mbp = mkDarwin { };
}
