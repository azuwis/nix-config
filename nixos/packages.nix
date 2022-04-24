{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--update-input home --update-input nixpkgs --update-input utils)
      else
        args=("$@")
      fi
      # --use-remote-sudo is needed, see https://github.com/NixOS/nixpkgs/issues/169193
      nixos-rebuild --use-remote-sudo switch --flake '/etc/nixos' ''${args[@]}
    '')
    compsize
    dnsutils
    efibootmgr
    iotop-c
    netproc
    nixos-option
  ];
}
