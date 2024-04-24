{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.emacs;
in
{
  options.my.emacs = {
    enable = mkEnableOption "emacs";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.emacs ];
    home.file.".doom.d".source = ./doom.d;
  };
}
