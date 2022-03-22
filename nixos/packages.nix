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
      sudo nixos-rebuild switch --flake '/etc/nixos' ''${args[@]}
    '')
    compsize
    efibootmgr
    iotop-c
    nixos-option
  ];
}
