{
  pkgs ? import ../pkgs { },
  ...
}:

let
  inputs = import ../inputs;
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };
  nix-config = pkgs.runCommand "nix-config" { preferLocalBuild = true; } ''
    mkdir -p $out
    ln -s ${../.} $out/nix-config
    ln -s $out/nix-config/scripts $out/bin
  '';
in

devshell.mkShell {
  packages = [
    nix-config
  ];
}
