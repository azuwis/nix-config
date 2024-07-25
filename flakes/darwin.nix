{
  inputs,
  self,
  withSystem,
  ...
}:

let
  mkDarwin =
    {
      system ? "aarch64-darwin",
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
      inputs.darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs inputs' lib;
          pkgs = if (nixpkgs != inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
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
