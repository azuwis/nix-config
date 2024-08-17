{
  inputs,
  self,
  withSystem,
  ...
}:

let
  mkDroid = import ./mk-system.nix {
    inherit inputs self withSystem;
    defaultSystem = "aarch64-linux";
    defaultModules = [ ../droid ];
    applyFunction =
      args@{ ... }:
      args.inputs.droid.lib.nixOnDroidConfiguration {
        inherit (args) pkgs modules;
        extraSpecialArgs = {
          inherit (args) inputs inputs' lib;
        };
      };
  };
in
{
  flake.nixOnDroidConfigurations.default = mkDroid { };

  # for CI
  flake.nixOnDroidConfigurations.droid = mkDroid { system = "x86_64-linux"; };
}
