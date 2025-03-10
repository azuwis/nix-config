{
  inputs,
  withSystem,
  ...
}:

let
  mkDarwin = import ./mk-system.nix {
    inherit inputs withSystem;
    defaultSystem = "aarch64-darwin";
    defaultModules = [ ../darwin ];
    apply =
      args@{ ... }:
      args.inputs.darwin.lib.darwinSystem {
        inherit (args) system modules;
        specialArgs = {
          inherit (args) pkgs;
        };
      };
  };
in
{
  flake.darwinConfigurations = {
    mbp = mkDarwin { modules = [ ../hosts/mbp.nix ]; };
  };
}
