{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    p7zip
    borgbackup
    curl
    gnupg
    htop
    less
    openssh
    pass-otp
    ripgrep
    shellcheck
    telnet
    watch
  ];
}
