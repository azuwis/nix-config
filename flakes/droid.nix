{ inputs, withSystem, ... }:

let
  mkDroid = { system, modules ? [ ] }: withSystem system ({ pkgs, system, ... }: inputs.droid.lib.nixOnDroidConfiguration {
    inherit pkgs system;
    modules = [
      ../common
      ../droid
    ] ++ modules;
  });
in
{
  flake.nixOnDroidConfigurations.droid = mkDroid { system = "aarch64-linux"; };
}
