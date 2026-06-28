{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.registry;

  inputs' =
    lib.filterAttrs
      (
        # Only set nix flake registry if the value is a Nix store path.
        # Non-store paths (e.g. from NIXLOCK_OVERRIDE_nixpkgs) force Nix to hash
        # the whole source tree on each evaluation, potentially also copying it
        # into the store.
        name: value: builtins.elem name cfg.entries && lib.isStorePath value
      )
      # NOTE: Make sure inputs are all strings, not paths, nix.registry use
      # builtins.toJSON, which will also copy paths to nix store
      # https://nix.dev/manual/nix/2.26/language/builtins#builtins-toJSON
      inputs;
in

{
  options.registry = {
    enable = lib.mkEnableOption "registry" // {
      default = true;
    };

    entries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  # ${nixpkgs}/nixos/modules/misc/nixpkgs-flake.nix
  # ${nixpkgs}/nixos/modules/config/nix-flakes.nix
  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (name: value: {
      name = "nix/inputs/${name}";
      value = {
        source = value;
      };
    }) inputs';

    nix.nixPath = [ "/etc/nix/inputs" ];

    nix.registry = {
      n.to = {
        id = "nixpkgs";
        type = "indirect";
      };
    }
    // builtins.mapAttrs (
      _: value:
      if builtins.isAttrs value then
        # Add lastModified/narHash/rev extra informations
        {
          flake = value;
        }
      else
        {
          to = {
            type = "path";
            path = value;
          };
        }
    ) inputs';

    registry.entries = [
      "agenix"
      "devshell"
      "nixpkgs"
    ];
  };
}
