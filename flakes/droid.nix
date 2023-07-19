{ inputs, withSystem, ... }:

let
  mkDroid = { system ? "aarch64-linux", modules ? [ ] }:
    withSystem system ({ lib, pkgs, system, ... }: inputs.droid.lib.nixOnDroidConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs lib; };
      modules = [
        ../common
        ../droid
      ] ++ modules;
    });
in
{
  flake.nixOnDroidConfigurations.droid = mkDroid { };
}
