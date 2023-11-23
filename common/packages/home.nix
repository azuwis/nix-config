{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pass.withExtensions (ext: [ ext.pass-otp ]))
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
    python3
    ripgrep
    rsync
    scripts
    shellcheck
    tmux
    tree
    ugrep
    unar
    unzip
    watch
    xz
    zstd
  ];
}
