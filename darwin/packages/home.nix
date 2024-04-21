{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      shift
      then
        args=(--update-input darwin --update-input home --update-input utils)
        if [ -n "$1" ]
        then
          args+=(--override-input nixpkgs "github:NixOS/nixpkgs/$1")
        else
          args+=(--update-input nixpkgs)
        fi
        nix flake lock ''${args[@]}
        shift
      fi
      darwin-rebuild switch --flake ~/.config/nixpkgs "''$@"
    '')
    (pkgs.runCommand "telnet-0.0.0" { } ''
      mkdir -p $out/bin $out/share/man/man1/
      ln -s ${pkgs.inetutils}/bin/telnet $out/bin/
      ln -s ${pkgs.inetutils}/share/man/man1/telnet.1.gz $out/share/man/man1/
    '')
    android-file-transfer
    android-tools
    blueutil
    coreutils-full
    daemon
    darwin.iproute2mac
    gimp
    pstree
    qbittorrent
    subfinder
  ];
}
