{ config, lib, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./git.nix
    ./mpv.nix
    ./my.nix
    ./nibar.nix
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
    pass-otp
    ripgrep
  ];
  programs.direnv.enable = true;
}
