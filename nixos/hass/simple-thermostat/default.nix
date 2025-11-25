{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.hass;
in
{
  options.services.hass = {
    simple-thermostat = mkEnableOption "hass";
  };

  config = mkIf (cfg.enable && cfg.simple-thermostat) {
    services.home-assistant.customLovelaceModules = [ pkgs.simple-thermostat ];
  };
}
