{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    braviatv = mkEnableOption (mdDoc "braviatv") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.braviatv) {
    services.home-assistant.extraPackages = ps: [ ps.pybravia ];
  };
}
