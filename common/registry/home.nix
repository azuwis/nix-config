{ inputs, config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.registry;

  flakes = lib.filterAttrs (name: value: builtins.elem name [ "nixpkgs" "home-manager" ]) inputs;
in
{
  options.my.registry = {
    enable = mkEnableOption "registry";
  };

  config = mkIf cfg.enable {
    nix.registry = builtins.mapAttrs
      (name: value: { flake = value; })
      flakes;
  };
}
