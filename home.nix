{ config, lib, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./git.nix
    ./kitty.nix
    ./mpv.nix
    ./my.nix
    ./skhd.nix
    ./squirrel.nix
    ./vim.nix
    ./zsh.nix
  ];
  home.packages = with pkgs; [
    coreutils-full
    curl
    gnupg
    htop
    hydra-check
    less
    pass-otp
    ripgrep
    watch
  ];
  programs.direnv.enable = true;
}
