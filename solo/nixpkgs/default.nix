{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.variables.NIX_PATH = "nixpkgs=${inputs.nixpkgs.outPath}";
}
