{ config, lib, pkgs, ... }:

{
  imports = [
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
