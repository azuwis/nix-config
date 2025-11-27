{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (pkgs.runCommand "telnet-0.0.0" { } ''
      mkdir -p $out/bin $out/share/man/man1/
      ln -s ${pkgs.inetutils}/bin/telnet $out/bin/
      ln -s ${pkgs.inetutils}/share/man/man1/telnet.1.gz $out/share/man/man1/
    '')
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
