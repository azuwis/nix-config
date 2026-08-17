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
    programs.direnv.nix-direnv.package = pkgs.nix-direnv;
    # Infinite recursion if `environment.variables.DIRENV_CONFIG = "${config.system.build.etc}/etc/direnv"`
    environment.variables.DIRENV_CONFIG = lib.mkForce null;
    programs.zsh.env.DIRENV_CONFIG = "${config.system.build.etc}/etc/direnv";
  };
}
