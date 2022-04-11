{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--update-input droid --update-input home --update-input nixpkgs --update-input utils)
      else
        args=("$@")
      fi
      nix-on-droid switch --flake "$HOME/.config/nixpkgs/#droid" ''${args[@]}
    '')
  ];
}
