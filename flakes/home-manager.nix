let
  inputs = import ../inputs;

  mkHome =
    {
      system,
      modules ? [ ],
    }:
    import (inputs.home-manager.outPath + "/modules") {
      pkgs = import ../pkgs { inherit system; };
      configuration.imports = [
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
        ../common/nixpkgs
        ../common/home.nix
      ]
      ++ modules;
    };
in

{
  azuwis = mkHome {
    system = "x86_64-linux";
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
    system = "x86_64-linux";
    modules = [
      {
        home.username = "deck";
        home.homeDirectory = "/home/deck";
        my.registry.enable = true;
      }
    ];
  };
}
