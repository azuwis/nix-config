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
    pciutils
    psmisc
    tcpdump
    usbutils
  ];
}
