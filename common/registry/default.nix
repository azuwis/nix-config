{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.registry;
in

{
  options.registry = {
    enable = lib.mkEnableOption "registry" // {
      default = true;
    };
  };

  # ${nixpkgs}/nixos/modules/misc/nixpkgs-flake.nix
  # ${nixpkgs}/nixos/modules/config/nix-flakes.nix
  config = lib.mkIf cfg.enable {
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

    # NOTE: Make sure inputs are not non-store paths, nix.registry use
    # builtins.toJSON, which will copy non-store paths to nix store
    # https://nix.dev/manual/nix/2.26/language/builtins#builtins-toJSON
    nix.registry = {
      n.to = {
        id = "nixpkgs";
        type = "indirect";
      };
    }
    # Only set nix flake registry if the value is a Nix store path.
    # Non-store paths (e.g. from NIXLOCK_OVERRIDE_nixpkgs) force Nix to hash
    # the whole source tree on each evaluation, potentially also copying it
    # into the store.
    // lib.optionalAttrs (lib.isStorePath inputs.nixpkgs) {
      nixpkgs.to =
        let
          nixpkgsInput = (import ../../inputs/inputs.nix).nixpkgs;
        in
        {
          inherit (nixpkgsInput) url ref;
          type = "git";
          shallow = true;
          rev = inputs.nixpkgs.rev;
        };
    };
  };
}
