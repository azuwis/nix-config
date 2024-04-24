{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.my.moonlight-cemuhook;
in
{
  options.my.moonlight-cemuhook = {
    enable = mkEnableOption "moonlight-cemuhook";
    package = mkPackageOption pkgs "moonlight-cemuhook" { };
  };

  config = mkIf cfg.enable {
    my.steam-devices.enable = true;

    environment.systemPackages = [ cfg.package ];
    networking.firewall.allowedUDPPorts = [ 26760 ];
  };
}
