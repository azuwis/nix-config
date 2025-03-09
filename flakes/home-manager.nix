{
  inputs,
  self,
  withSystem,
  ...
}:

let
  mkHome = import ./mk-system.nix {
    inherit inputs withSystem;
    defaultSystem = "x86_64-linux";
    defaultModules = [
      (
        { lib, pkgs, ... }:
        {
          news.display = "silent";
          news.json = lib.mkForce { };
          news.entries = lib.mkForce [ ];
          # set the same option as home-manager in nixos/nix-darwin, to generate the same derivation
          nix.package = pkgs.nix;
        }
      )
      ../common/home.nix
    ];
    apply =
      args@{ ... }:
      args.inputs.home-manager.lib.homeManagerConfiguration {
        inherit (args) pkgs modules;
      };
  };
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
