{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.emacs;
in
{
  options.my.emacs = {
    enable = mkEnableOption (mdDoc "emacs");
  };

  config = mkIf cfg.enable {
    hm.my.emacs.enable = true;

    fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
  };
}
