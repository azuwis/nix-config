{ config, lib, pkgs, ... }:

{
  services.home-assistant.config = {
    frontend.themes.custom = {
      modes.light.state-icon-active-color = "#F57F17";
      modes.dark.state-icon-active-color = "#F57F17";
    };
    automation = [{
      alias = "Set theme";
      trigger = [{
        platform = "homeassistant";
        event = "start";
      }];
      action = {
        service = "frontend.set_theme";
        data.name = "custom";
      };
    }];
  };
}
