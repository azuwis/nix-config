{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nix;
in

{
  options.nix = {
    enable = lib.mkEnableOption "nix" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/nix/registry.json".source = config.environment.etc."nix/registry.json".source;
  };
}
