{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.my.firefox;
in
{
  config = mkIf cfg.enable {
    programs.firefox.package = null;
  };
}
