{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--recreate-lock-file)
      else
        args=("$@")
      fi
      nix-on-droid switch --flake "$HOME/.config/nixpkgs/#droid" ''${args[@]}
    '')
    inetutils
    procps
  ];
}
