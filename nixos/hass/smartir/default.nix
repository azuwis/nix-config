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
    smartir = mkEnableOption "smartir";
  };

  config = mkIf (cfg.enable && cfg.smartir) {
    services.home-assistant.customComponents = [
      (pkgs.home-assistant-custom-components.smartir.overridePythonAttrs (old: {
        # Add `Off` to `sources` for R2000DB, useful to synchronize power state
        postInstall = (old.postInstall or "") + ''
          cp -r ${./codes}/* $out/custom_components/smartir/codes/
        '';
      }))
    ];
    services.home-assistant.extraComponents = [ "broadlink" ];

    services.home-assistant.config = {
      smartir.check_updates = false;
      media_player = [
        {
          platform = "smartir";
          name = "Edifier R2000DB";
          device_code = 1461;
          controller_data = "remote.broadlink1";
        }
      ];
      homeassistant.customize."media_player.edifier_r2000db".icon = "mdi:speaker";
      # logger.logs."custom_components.smartir" = "debug";
    };
  };
}
