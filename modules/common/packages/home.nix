{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pass.withExtensions(ext: [ ext.pass-otp ]))
    age
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
    jq
    less
    lsof
    man
    netcat-gnu
    nix-tree
    openssh
    openssl
    p7zip
    ripgrep
    rsync
    scripts
    shellcheck
    tmux
    tree
    unar
    unzip
    watch
    xz
    zstd
  ];
}