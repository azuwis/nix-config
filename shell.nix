# Provide a dummy shell for nixpkgs/maintainers/scripts/update.py, used by ./scripts/update

{
  pkgs ? import ./pkgs { },
  ...
}:

pkgs.mkShellNoCC { }
