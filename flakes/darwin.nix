{ inputs, withSystem, ... }:

let
  mkDarwin =
    {
      system ? "aarch64-darwin",
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
      inputs.darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            inputs'
            lib
            pkgs
            ;
        };
        modules = [ ../darwin ] ++ modules;
      }
    );
in
{
  flake.darwinConfigurations = {
    mbp = mkDarwin { modules = [ ../hosts/mbp.nix ]; };

    # For CI
    test = mkDarwin {
      system = "x86_64-darwin";
      modules = [ ../hosts/mbp.nix ];
    };
  };
}
