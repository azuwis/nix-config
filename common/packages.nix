{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    borgbackup
    bzip2
    curl
    diffutils
    file
    findutils
    gawk
    gnugrep
    gnupg
    gnused
    gnutar
    gzip
    htop
    imagemagick
    ipcalc
    less
    man
    openssh
    p7zip
    pass-otp
    ripgrep
    rsync
    scripts
    shellcheck
    telnet
    tree
    unrar
    unzip
    watch
    xz
  ];
}
