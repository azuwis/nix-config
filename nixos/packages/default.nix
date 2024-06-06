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
