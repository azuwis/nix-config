{
  pkgs ? import ../pkgs { },
  ...
}:

let
  inputs = import ../inputs;
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };
  eval = (import ../flakes/solo.nix).solo;
in

devshell.mkShell {
  devshell.startup.zsh.text = ''
    exec -a -zsh "${eval.config.environment.shell}/bin/zsh"
  '';

  packages = eval.config.environment.systemPackages;
}
