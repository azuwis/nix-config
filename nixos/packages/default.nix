{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    compsize
    dnsutils
    efibootmgr
    ethtool
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
