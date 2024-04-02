{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkPackageOptionMD;
  cfg = config.my.dualsensectl;
in
{
  options.my.dualsensectl = {
    enable = mkEnableOption "dualsensectl";
    package = mkPackageOptionMD pkgs "dualsensectl" { };
  };

  config = mkIf cfg.enable {
    my.steam-devices.enable = true;

    environment.systemPackages = [ cfg.package ];
  };
}
