{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkPackageOptionMD;
  cfg = config.my.moonlight-cemuhook;
in
{
  options.my.moonlight-cemuhook = {
    enable = mkEnableOption "moonlight-cemuhook";
    package = mkPackageOptionMD pkgs "moonlight-cemuhook" { };
  };

  config = mkIf cfg.enable {
    my.steam-devices.enable = true;

    environment.systemPackages = [ cfg.package ];
    networking.firewall.allowedUDPPorts = [ 26760 ];
  };
}
