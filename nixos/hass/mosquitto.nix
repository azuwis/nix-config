{ config, lib, pkgs, ...}:

{
  services.mosquitto = {
    enable = true;
    listeners = [{
      address = "127.0.0.1";
      settings = {
        allow_anonymous = true;
      };
    }];
  };
}
