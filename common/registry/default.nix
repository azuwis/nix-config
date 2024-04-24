{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  flakes = lib.filterAttrs (
    name: value:
    builtins.elem name [
      "nixpkgs"
      "home-manager"
    ]
  ) inputs;
in
{
  # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/master/lib/options.nix
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/inputs/${name}";
    value = {
      source = value.outPath;
    };
  }) flakes;
  nix.nixPath = [ "/etc/nix/inputs" ];
  nix.registry = builtins.mapAttrs (name: value: { flake = value; }) flakes;
}
