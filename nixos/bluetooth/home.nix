{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.bluetooth;
in
{
  options.my.bluetooth = {
    enable = mkEnableOption (mdDoc "bluetooth");
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ bluetuith ];
  };
}
