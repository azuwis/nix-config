{ config, lib, pkgs, ... }:

let
  www = ./www;
in

{
  services.nginx.virtualHosts.hass = {
    locations."/local/" = {
      alias = "${www}/";
    };
  };

  services.home-assistant.config.lovelace.mode = "yaml";
  services.home-assistant.config.lovelace.resources =
  let
    mkModule = name:
    let
      hash = builtins.hashFile "md5" "${www}/${name}.js";
    in {
      url = "/local/${name}.js?v=${hash}";
      type = "module";
    };
  in [
    # (mkModule "glance-card")
    # (mkModule "state-icon")
  ];
}
