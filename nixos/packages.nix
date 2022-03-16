{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--update-input nixos --update-input nixosHm)
      else
        args=("$@")
      fi
      sudo nixos-rebuild switch --flake '/etc/nixos' ''${args[@]}
    '')
    compsize
    efibootmgr
    iotop-c
  ];
}
