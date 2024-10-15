{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.editorconfig;
in
{
  options.my.editorconfig = {
    enable = mkEnableOption "editorconfig";
  };

  config = mkIf cfg.enable {
    home.file.".editorconfig".source = ../../.editorconfig;
  };
}
