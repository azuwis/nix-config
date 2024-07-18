{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    simple-thermostat = mkEnableOption "hass";
  };

  config = mkIf (cfg.enable && cfg.simple-thermostat) {
    services.home-assistant.customLovelaceModules = [ pkgs.simple-thermostat ];
  };
}
