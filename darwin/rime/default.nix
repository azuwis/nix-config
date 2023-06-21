{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.rime;
in
{
  options.my.rime = {
    enable = mkEnableOption (mdDoc "rime");
  };

  config = mkIf cfg.enable {
    hm.my.rime.enable = true;

    homebrew.casks = mkIf config.homebrew.enable [ "squirrel" ];
  };
}
