{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      pushd ~/.config/nixpkgs || exit
      if [ "$1" = "u" ]
      shift
      then
        args=(--update-input darwin --update-input darwinHm)
        if [ -n "$1" ]
        then
          args+=(--override-input darwinNixpkgs "github:NixOS/nixpkgs/$1")
        else
          args+=(--update-input darwinNixpkgs)
        fi
        nix flake lock ''${args[@]}
        shift
      fi
      darwin-rebuild switch --flake . "''$@"
      popd || exit
    '')
    coreutils-full
    daemon
    element-desktop
    hydra-check
  ];
}
