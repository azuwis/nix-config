{ config, lib, pkgs, ... }:

{
  services.home-assistant.config = {
    frontend.themes.custom = {
      modes.light.state-icon-active-color = "#F57F17";
      modes.dark.state-icon-active-color = "#F57F17";
    };
  };
  hass.automations = ''
    - alias: Set theme
      trigger:
        - event: start
          platform: homeassistant
      action:
        service: frontend.set_theme
        data:
          name: custom
  '';
}
