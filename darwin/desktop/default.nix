{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.desktop;

in
{
  options.my.desktop = {
    enable = mkEnableOption "desktop";
  };

  config = mkIf cfg.enable {
    hm.my.desktop.enable = true;

    my.emacs.enable = true;
    my.firefox.enable = true;
    my.rime.enable = true;
  };
}
