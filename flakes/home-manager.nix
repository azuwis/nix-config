{ self, withSystem, ... }:

let
  mkHome =
    { system ? "x86_64-linux"
    , nixpkgs ? self.inputs.nixpkgs
    , config ? { }
    , overlays ? [ ]
    , modules ? [ ]
    }:
    withSystem system ({ lib, pkgs, system, ... }:
    let
      customPkgs = import nixpkgs (lib.recursiveUpdate
        {
          inherit system;
          overlays = [ self.overlays.default ] ++ overlays;
          config.allowUnfree = true;
        }
        {
          inherit config;
        }
      );
    in
    self.inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = if (nixpkgs != self.inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
      extraSpecialArgs = {
        lib = import (self.inputs.home-manager + "/modules/lib/stdlib-extended.nix") lib;
        inputs = self.inputs;
      };
      modules = [{
        imports = lib.my.getHmModules [ ../common ];
        home.stateVersion = "23.11";
        programs.home-manager.enable = true;
      }] ++ modules;
    });
in
{
  flake.homeConfigurations = {
    azuwis = mkHome {
      modules = [{
        home.username = "azuwis";
        home.homeDirectory = "/home/azuwis";
      }];
    };

    "azuwis@mbp" = mkHome {
      system = "aarch64-darwin";
      modules = [{
        home.username = "azuwis";
        home.homeDirectory = "/Users/azuwis";
      }];
    };

    deck = mkHome {
      modules = [{
        home.username = "deck";
        home.homeDirectory = "/home/deck";
      }];
    };
  };

  perSystem = { system, pkgs, ... }: {
    apps.init-home.program = pkgs.writeShellScriptBin "init-home" ''
      ${self.inputs.home-manager.packages.${system}.default}/bin/home-manager --extra-experimental-features "nix-command flakes" switch --flake "${self}" "$@"
    '';
  };
}
