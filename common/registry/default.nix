{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.settings.registry;

  inputs' =
    lib.filterAttrs
      (
        # Only set nixpkgs registry if in nix store
        # When NPINS_OVERRIDE_nixpkgs is used, nixpkgs registry will be something like
        # `path:/home/user/src/nixpkgs`, and then `nix run nixpkgs#foo` will copy the
        # entire nixpkgs repo into nix store
        name: value: builtins.elem name cfg.entries && lib.hasPrefix builtins.storeDir value
      )
      (
        # Use toString to avoid copying inputs to nix store if NPINS_OVERRIDE_* is used
        # nix.registry use builtins.toJSON, which will also copy paths to nix store
        # https://nix.dev/manual/nix/2.26/language/builtins#builtins-toJSON
        builtins.mapAttrs (_: value: toString value.outPath) inputs
      );
in

{
  options.settings.registry = {
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
    // builtins.mapAttrs (_: value: {
      to = {
        type = "path";
        path = value;
      };
    }) inputs';

    settings.registry.entries = [
      "agenix"
      "nixpkgs"
    ];
  };
}
