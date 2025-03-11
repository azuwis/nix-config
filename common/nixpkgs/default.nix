{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.nixpkgs;
  inputs = import ../../inputs;
in
{
  options.my.nixpkgs = {
    enable = mkEnableOption "nixpkgs" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs = {
      config = import ../../config.nix;
      overlays = (import ../../overlays { inherit inputs; });
    };
  };
}
