{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    android-file-transfer
    android-tools
    blueutil
    coreutils-full
    daemon
    # gimp2
    iproute2mac
    pstree
    # qbittorrent
  ];
}
