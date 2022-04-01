{ config, lib, pkgs, ... }:

let
  hassConfig = ./config;
in

{
  services.nginx.virtualHosts.hass = {
    locations."/local/" = {
      alias = "${hassConfig}/www/";
    };
  };

  services.home-assistant.config.lovelace.mode = "yaml";
  services.home-assistant.config.lovelace.resources =
  let
    mkModule = name:
    let
      hash = builtins.hashFile "md5" "${hassConfig}/www/${name}.js";
    in {
      url = "/local/${name}.js?v=${hash}";
      type = "module";
    };
  in [
    (mkModule "glance-card")
    (mkModule "state-icon")
  ];
}
