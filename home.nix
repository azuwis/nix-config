{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./my.nix
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
