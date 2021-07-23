{ config, lib, pkgs, ... }:

with lib;

{
  # nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
  # nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
  imports = [
    <home-manager/nix-darwin>
    ./home.nix
    ./homebrew.nix
    ./spacebar.nix
    ./sudo.nix
    ./system.nix
    ./vim.nix
    ./yabai.nix
  ];

  options.my = {
    user = mkOption {
      type = types.str;
    };
    name = lib.mkOption {
      type = types.str;
    };
    email = lib.mkOption {
      type = types.str;
    };
  };

  config = {
    my = {
      user = "azuwis";
      name = "Zhong Jianxin";
      email = "azuwis@gmail.com";
    };
  };
}
