{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.editorconfig;
in
{
  options.programs.editorconfig = {
    enable = mkEnableOption "editorconfig";
  };

  config = mkIf cfg.enable {
    home.file.".editorconfig".source = ../../.editorconfig;
  };
}
