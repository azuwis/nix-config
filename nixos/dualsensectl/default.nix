{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkPackageOptionMD;
  cfg = config.my.dualsensectl;
in
{
  options.my.dualsensectl = {
    enable = mkEnableOption (mdDoc "dualsensectl");
    package = mkPackageOptionMD pkgs "dualsensectl" { };
  };

  config = mkIf cfg.enable {
    my.steam-devices.enable = true;

    environment.systemPackages = [ cfg.package ];
  };
}
