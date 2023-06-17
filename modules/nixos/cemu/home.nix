{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.cemu;
in 
{
  options.my.cemu = {
    enable = mkEnableOption (mdDoc "cemu");
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.cemu ]; 
  };
}
