{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.direnv;
in

{
  config = lib.mkIf cfg.enable {
    # DIRENV_CONFIG set by solo/zsh/default.nix to avoid infinite recursion
    environment.variables.DIRENV_CONFIG = lib.mkForce null;
    programs.direnv.nix-direnv.package = pkgs.nix-direnv;
  };
}
