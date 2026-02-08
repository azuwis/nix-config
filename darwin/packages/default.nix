{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # android-file-transfer bump to use fuse3, not available in nixpkgs' macfuse yet
    # https://github.com/NixOS/nixpkgs/pull/458276
    # android-file-transfer
    android-tools
    blueutil
    coreutils-full
    daemon
    # gimp2
    iproute2mac
    pstree
    qbittorrent
  ];
}
