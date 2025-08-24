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
  env = builtins.attrValues (
    builtins.mapAttrs (name: value: {
      inherit name value;
    }) eval.config.environment.variables
  );

  devshell.startup.zsh.text = ''
    exec -a -zsh "${eval.config.environment.shell}/bin/zsh"
  '';

  packages = eval.config.environment.systemPackages;
}
