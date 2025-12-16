{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (pass.withExtensions (ext: [ ext.pass-otp ]))
    _7zz
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
    # Higher priority than libressl.nc # https://github.com/NixOS/nixpkgs/pull/470191
    (lib.hiPrio netcat)
    ncurses # clear, reset
    # nix-output-monitor
    nix-tree
    npins
    nvd
    openssh
    openssl
    python3
    ripgrep
    rsync
    scripts
    shellcheck
    tmux
    tree
    ugrep
    unar
    watch
    xz
    zstd
  ];
}
