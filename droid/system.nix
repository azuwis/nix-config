{ pkgs, config, ... }:

{
  environment.packages = with pkgs; [
    vim
    #fmenu
    diffutils
    findutils
    #utillinux
    #tzdata
    #hostname
    man
    gnugrep
    gnused
    gnutar
    bzip2
    gzip
    xz
    unzip
    curl
    openssh
    htop
    git
    rsync
    pass-otp
    gnupg
    pinentry-curses
    zsh
  ];

  environment.etcBackupExtension = ".bak";
  system.stateVersion = "21.05";
  user.shell = "${pkgs.zsh}/bin/zsh";
}
