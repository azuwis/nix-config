{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Failed to build against btrfs-progs v6.10.1
    # compsize
    dnsutils
    efibootmgr
    git
    inetutils
    iotop-c
    man-pages
    nixos-option
    pciutils
    psmisc
    tcpdump
    usbutils
  ];
}
