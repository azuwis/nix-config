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
    hardware.bluetooth.enable = true;
    environment.systemPackages = [ pkgs.bluetuith ];
  };
}
