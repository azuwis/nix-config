{ config, lib, pkgs, ... }:

{
  services.home-assistant.config.device_tracker = [{
    platform = "ubus";
    host = "xr500.lan";
    username = "hass";
    password = "!secret ubus_password";
    dhcp_software = "none";
    consider_home = 20;
    new_device_defaults.track_new_devices = false;
  }];
}
