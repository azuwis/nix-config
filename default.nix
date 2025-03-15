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

  mkDroid =
    {
      system,
      modules ? [ ],
    }:
    import "${inputs.nix-on-droid.outPath}/modules" {
      pkgs = import ./pkgs { inherit system; };
      targetSystem = system;
      home-manager-path = inputs.home-manager.outPath;
      config.imports = [
        { my.nixpkgs.enable = false; }
        ./droid
      ] ++ modules;
      # Prevent nix-on-droid from using <nixpkgs>, see nix-on-droid/modules/nixpkgs/config.nix
      isFlake = true;
    };

  nixOnDroidConfigurations.default = mkDroid { system = "aarch64-linux"; };
  # for CI
  nixOnDroidConfigurations.droid = mkDroid { system = "x86_64-linux"; };
in

{
  inherit
    nixosConfigurations
    darwinConfigurations
    nixOnDroidConfigurations
    ;
}
