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

  config = mkIf cfg.enable (
    let
      # Use toString to avoid copying nixpkgs to nix store if NPINS_OVERRIDE_nixpkgs is used
      # nix.registry use builtins.toJSON, which will also copy paths to nix store
      # https://nix.dev/manual/nix/2.26/language/builtins#builtins-toJSON
      nixpkgs = toString inputs.nixpkgs.outPath;
    in
    {
      # ${nixpkgs}/nixos/modules/misc/nixpkgs-flake.nix
      # ${nixpkgs}/nixos/modules/config/nix-flakes.nix
      environment.etc."nix/inputs/nixpkgs".source = nixpkgs;
      nix.nixPath = [ "/etc/nix/inputs" ];
      nix.registry = {
        n.to = {
          id = "nixpkgs";
          type = "indirect";
        };
      }
      // lib.optionalAttrs (lib.hasPrefix "/nix/store/" nixpkgs) {
        # Only set nixpkgs registry if in nix store
        # When NPINS_OVERRIDE_nixpkgs is used, nixpkgs registry will be something like
        # `path:/home/user/src/nixpkgs`, and then `nix run nixpkgs#foo` will copy the
        # entire nixpkgs repo into nix store
        nixpkgs.to = {
          type = "path";
          path = nixpkgs;
        };
      };
    }
  );
}
