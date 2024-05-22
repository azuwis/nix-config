{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.registry;

  flakes = lib.filterAttrs (
    name: value:
    builtins.elem name [
      "nixpkgs"
      "home-manager"
    ]
  ) inputs;
in
{
  options.my.registry = {
    enable = mkEnableOption "registry" // {
      # https://github.com/NixOS/nixpkgs/pull/254405/commits/e456032addae76701eb17e6c03fc515fd78ad74f
      default = !(config.nixpkgs ? flake && config.nixpkgs.flake.source == null);
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/master/lib/options.nix
    environment.etc = lib.mapAttrs' (name: value: {
      name = "nix/inputs/${name}";
      value = {
        source = value.outPath;
      };
    }) flakes;
    nix.nixPath = [ "/etc/nix/inputs" ];
    nix.registry = builtins.mapAttrs (name: value: { flake = value; }) flakes;
  };
}
