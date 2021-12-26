{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--update-input darwin --update-input darwinHm --update-input darwinNixpkgs)
      else
        args=("$@")
      fi
      pushd ~/.config/nixpkgs || exit
      darwin-rebuild switch --flake . ''${args[@]}
      popd || exit
    '')
    coreutils-full
    daemon
    element-desktop
    hydra-check
  ];
}
