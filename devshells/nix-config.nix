let
  inputs = import ../inputs;
  pkgs = import ../pkgs { };
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };
  nix-config = pkgs.runCommand "nix-config" { } ''
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
