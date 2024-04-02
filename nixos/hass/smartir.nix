{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    smartir = mkEnableOption "smartir" // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.smartir) {
    services.home-assistant.customComponents = [ pkgs.smartir ];

    services.home-assistant.config = {
      smartir.check_updates = false;
      media_player = [{
        platform = "smartir";
        name = "Edifier R2000DB";
        device_code = 1461;
        controller_data = "remote.broadlink1";
      }];
      homeassistant.customize."media_player.edifier_r2000db".icon = "mdi:speaker";
      # logger.logs."custom_components.smartir" = "debug";
    };
  };
}
