{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    borgbackup
    bzip2
    curl
    diffutils
    findutils
    file
    gawk
    gnugrep
    gnupg
    gnused
    gnutar
    gzip
    htop
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
    unzip
    watch
    xz
  ];
}
