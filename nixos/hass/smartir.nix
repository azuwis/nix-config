{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;

  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "smartHomeHub";
    repo = "SmartIR";
    rev = "1f8e95b8a6e062038e5698ed438ecee4321b496f";
    sha256 = "sha256-/jnEkpN2TH8QhkwN4WmaGFjfY4hWzHTZ29vhnaD22RM=";
  };
in
{
  options.my.hass = {
    smartir = mkEnableOption (mdDoc "smartir") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.smartir) {
    hass.file."custom_components/smartir" = {
      source = "${component}/custom_components/smartir";
      recursive = true;
    };
    hass.file."custom_components/smartir/codes".source = "${component}/codes";

    services.home-assistant.extraPackages = ps: with ps; [
      broadlink
    ];

    services.home-assistant.config = {
      smartir.check_updates = false;
      media_player = [{
        platform = "smartir";
        name = "Edifier R2000DB";
        device_code = 1500;
        controller_data = "remote.broadlink1";
      }];
      homeassistant.customize."media_player.edifier_r2000db".icon = "mdi:speaker";
      # logger.logs."custom_components.smartir" = "debug";
    };
  };
}
