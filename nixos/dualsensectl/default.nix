{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.my.dualsensectl;
in
{
  options.my.dualsensectl = {
    enable = mkEnableOption "dualsensectl";
    package = mkPackageOption pkgs "dualsensectl" { };
  };

  config = mkIf cfg.enable {
    my.steam-devices.enable = true;

    environment.systemPackages = [ cfg.package ];
  };
}
