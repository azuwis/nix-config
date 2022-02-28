{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pass.withExtensions(ext: [ ext.pass-otp ]))
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
    inetutils
    ipcalc
    less
    man
    netcat
    nix-tree
    openssh
    p7zip
    ripgrep
    rsync
    scripts
    shellcheck
    tree
    unar
    unzip
    watch
    xz
    zstd
  ];
}
