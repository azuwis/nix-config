{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.moonlight-cemuhook;
in
{
  options.my.moonlight-cemuhook = {
    enable = mkEnableOption (mdDoc "moonlight-cemuhook");
  };

  config = mkIf cfg.enable {
    my.steam-devices.enable = true;
    hm.my.moonlight-cemuhook.enable = true;
    networking.firewall.allowedUDPPorts = [ 26760 ];
  };
}
