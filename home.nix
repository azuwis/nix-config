{ config, lib, pkgs, ... }:

{
  imports = import ./modules.nix { inherit lib; };
  home.packages = with pkgs; [
    p7zip
    borgbackup
    coreutils-full
    curl
    fmenu
    gnupg
    htop
    hydra-check
    less
    openssh
    pass-otp
    ripgrep
    shellcheck
    telnet
    watch
    wireguard
  ];
}
