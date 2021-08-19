{ config, lib, pkgs, ... }:

{
  # nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
  # nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
  imports = [
    <home-manager/nix-darwin>
    ./alacritty.nix
    ./git.nix
    ./home-manager.nix
    ./homebrew.nix
    ./lorri.nix
    ./mpv.nix
    ./nibar.nix
    ./squirrel.nix
    ./sudo.nix
    ./system.nix
    ./vim.nix
    ./yabai.nix
    ./zsh.nix
  ];

  options.my = {
    user = lib.mkOption {
      type = lib.types.str;
    };
    name = lib.mkOption {
      type = lib.types.str;
    };
    email = lib.mkOption {
      type = lib.types.str;
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
