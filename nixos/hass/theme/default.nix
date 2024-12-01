{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.my.hass.enable {
    services.home-assistant.config = {
      frontend.themes.custom = {
        modes.light.state-icon-active-color = "#F57F17";
        modes.dark.state-icon-active-color = "#F57F17";
      };
    };
    hass.automations = ''
      - alias: Set theme
        triggers:
          - trigger: homeassistant
            event: start
        actions:
          - action: frontend.set_theme
            data:
              name: custom
    '';
  };
}
