{
  inputs,
  self,
  withSystem,
  ...
}:

let
  mkHome =
    {
      system ? "x86_64-linux",
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
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = if (nixpkgs != inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
        extraSpecialArgs = {
          inherit inputs inputs';
          lib = import (inputs.home-manager + "/modules/lib/stdlib-extended.nix") lib;
        };
        modules = [
          {
            news.display = "silent";
            news.json = lib.mkForce { };
            news.entries = lib.mkForce [ ];
            # set the same option as home-manager in nixos/nix-darwin, to generate the same derivation
            nix.package = pkgs.nix;
          }
          ../common/home.nix
        ] ++ modules;
      }
    );
in
{
  flake.homeConfigurations = {
    azuwis = mkHome {
      modules = [
        {
          home.username = "azuwis";
          home.homeDirectory = "/home/azuwis";
        }
      ];
    };

    "azuwis@mbp" = mkHome {
      system = "aarch64-darwin";
      modules = [
        {
          home.username = "azuwis";
          home.homeDirectory = "/Users/azuwis";
          my.desktop.enable = true;
          my.firefox.enable = true;
          my.rime.enable = true;
          my.emacs.enable = true;
        }
        ../darwin/home.nix
      ];
    };

    deck = mkHome {
      modules = [
        {
          home.username = "deck";
          home.homeDirectory = "/home/deck";
          my.registry.enable = true;
        }
      ];
    };
  };

  perSystem =
    {
      self',
      inputs',
      pkgs,
      ...
    }:
    {
      packages.home-manager = inputs'.home-manager.packages.default;
      apps.init-home.program = pkgs.writeShellScriptBin "init-home" ''
        ${self'.packages.home-manager}/bin/home-manager --extra-experimental-features "nix-command flakes" switch --flake "${self}" "$@"
      '';
    };
}
