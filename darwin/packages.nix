{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      pushd ~/.config/nixpkgs || exit
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
      darwin-rebuild switch --flake . "''$@"
      popd || exit
    '')
    android-file-transfer
    coreutils-full
    daemon
    element-desktop
    hydra-check
    (darwin.iproute2mac.overrideAttrs (o: rec {
      postPatch = "";
    }))
    # losslesscut-bin
  ];
}
