{ config, lib, pkgs, ... }:

{
  imports = [
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
    pass-otp
    ripgrep
    watch
  ];
  programs.direnv.enable = true;
}
