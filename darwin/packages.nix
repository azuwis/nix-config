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
    ((darwin.iproute2mac.override { python2 = pkgs.python3; })
    .overrideAttrs (o: rec {
      version = "1.3.0";
      src = fetchFromGitHub {
        owner = "brona";
        repo = "iproute2mac";
        rev = "v${version}";
        sha256 = "sha256-Xz/8OHn7BEM8L4BnFB2AhQ7sZTY9euYvFZBGSo5fl+0=";
      };
      postPatch = "";
    }))
    # losslesscut-bin
  ];
}
