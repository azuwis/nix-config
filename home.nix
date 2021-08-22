{ config, lib, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./git.nix
    ./my.nix
    ./zsh.nix
  ];
  home.packages = with pkgs; [
    coreutils-full
    curl
    gnupg
    htop
    hydra-check
    pass-otp
    ripgrep
  ];
}
