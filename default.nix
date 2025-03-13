let
  inputs = import ./inputs;
  nixpkgs = inputs.nixpkgs.outPath;
  lib = import "${nixpkgs}/lib";

  mkNixos =
    host:
    import "${nixpkgs}/nixos/lib/eval-config.nix" {
      system = null;
      modules = [
        (./hosts + "/${host}.nix") # compatible syntax with nix 2.3
      ];
    };

  nixosConfigurations = lib.genAttrs [
    "hyperv"
    "nuc"
    "steamdeck"
    "tuf"
    "utm"
    "wsl"
  ] mkNixos;

  mkDarwin =
    host:
    import "${inputs.nix-darwin.outPath}/eval-config.nix" {
      inherit lib;
      modules = [
        (./hosts + "/${host}.nix")
      ];
    };

  darwinConfigurations = lib.genAttrs [
    "mbp"
  ] mkDarwin;

  mkDroid = import "${inputs.nix-on-droid.outPath}/modules" {
    home-manager-path = inputs.home-manager.outPath;
    config.imports = [ ./droid ];
  };

  nixOnDroidConfigurations.default = mkDroid;
  # for CI
  nixOnDroidConfigurations.droid = mkDroid;
in

{
  inherit
    nixosConfigurations
    darwinConfigurations
    nixOnDroidConfigurations
    ;
}
