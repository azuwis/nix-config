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
    enable = mkEnableOption "registry";
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
