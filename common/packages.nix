{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    borgbackup
    bzip2
    curl
    diffutils
    findutils
    gnugrep
    gnupg
    gnused
    gnutar
    gzip
    htop
    less
    man
    openssh
    p7zip
    pass-otp
    ripgrep
    rsync
    shellcheck
    telnet
    unzip
    watch
    xz
  ];
}
