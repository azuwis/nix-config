{ config, lib, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./git.nix
    ./kitty.nix
    ./mpv.nix
    ./my.nix
    ./neovim.nix
    ./skhd.nix
    ./squirrel.nix
    ./zsh.nix
  ];
  home.packages = with pkgs; [
    coreutils-full
    curl
    gnupg
    htop
    hydra-check
    less
    openssh_8_7
    pass-otp
    passmenu
    ripgrep
    watch
  ];
  programs.direnv.enable = true;
}
