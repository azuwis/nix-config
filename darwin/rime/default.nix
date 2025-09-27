{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.programs.rime;
in
{
  config = mkIf cfg.enable {
    homebrew.casks = mkIf config.homebrew.enable [ "squirrel-app" ];
  };
}
