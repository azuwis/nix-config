{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.packages = with pkgs; [
    (writeScriptBin "bs" ''
      #!${runtimeShell}
      if [ "$1" = "u" ]
      then
        args=(--recreate-lock-file)
      else
        args=("$@")
      fi
      nix-on-droid switch --flake "$HOME/.config/nixpkgs" ''${args[@]}
    '')
    inetutils
    procps
  ];
}
