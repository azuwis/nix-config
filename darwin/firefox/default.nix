{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.firefox;

in
{
  options.my.firefox = {
    enable = mkEnableOption (mdDoc "firefox");
  };

  config = mkIf cfg.enable {
    hm.my.firefox.enable = true;

    homebrew.casks = [ "firefox" ];
  };
}
