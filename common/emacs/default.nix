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
    hm.my.emacs.enable = true;

    fonts.packages = [ pkgs.emacs-all-the-icons-fonts ];
  };
}
