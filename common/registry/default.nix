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
in
{
  options.my.registry = {
    enable = mkEnableOption "registry" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # ${nixpkgs}/nixos/modules/misc/nixpkgs-flake.nix
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nix.registry = {
      n.to = {
        id = "nixpkgs";
        type = "indirect";
      };
      nixpkgs.to = {
        type = "path";
        path = inputs.nixpkgs.outPath;
      };
    };
  };
}
